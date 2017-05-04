<#--stop if $modelPackage is null-->
<#if !(modelPackage)??>  ${metafactory.error("modelPackage not found in context")} </#if>
<#---->
<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>
<#---->
<#--stop if $modelReference is null-->
<#if !(modelReference)??>  <#stop "modelReference not found in context" ></#if>
<#---->
<#assign modelObjectName = modelObject.name>
<#assign modelObjectNameFL = modelObjectName?uncap_first>
<#assign modelObjectNamePL = modelObject.getMetaData("name.plural", "${modelObjectName}s")>
<#assign modelObjectNamePLFL = modelObjectNamePL?uncap_first>

<#assign referenceName = modelReference.name>
<#assign referenceNameFU = referenceName?cap_first >
<#assign referenceType = modelReference.type>
<#assign multiplicity = modelReference.multiplicity>
<#assign referenceClassName = metafactory.evaluateExpression("${'$'}{pattern.property.model.implementation.reference}", context) >
<#assign referenceObjectElement = modelPackage.findObjectByName(referenceType)>
<#assign referencePluralProperty = referenceObjectElement.getMetaData("name.plural")>
<#assign referencePluralPropertyFL = referencePluralProperty?uncap_first >

<#assign packageName = metafactory.evaluateExpression("${'$'}{pattern.property.model.implementation.package}", context) >

<#assign isEnum = referenceObjectElement.getMetaData("enum")>

<#assign projectSpecificSearchProperty = modelReference.getMetaData("projectspecific.fillComboForEdit", "false")>
<#assign projectSpecificSearch = modelReference.hasMetaData("projectspecific.fillComboForEdit", "true")>
<#if projectSpecificSearch >
  <#assign body>
    <@createBodyUsingJPA2 />
  </#assign>
  ${metafactory.evaluateFreeMarkerSnippet("projectspecific.java.cdi.beans.fillReferenceTypeComboForEdit", body)}
<#else>
  <@createBodyUsingJPA2 />
</#if>

<#------------------------------------------------------------------------------------------------------>
<#macro createBodyUsingJPA2 >
<#--
  ${metafactory.addLibraryToClass("java.util.ArrayList")}
  return new ArrayList<${referenceClassName}>();
-->
  ${metafactory.addLibraryToClass("javax.persistence.criteria.CriteriaBuilder")}
  ${metafactory.addLibraryToClass("javax.persistence.criteria.CriteriaQuery")}
  ${metafactory.addLibraryToClass("javax.persistence.criteria.Root")}
  ${metafactory.addLibraryToClass("javax.persistence.TypedQuery")}
  ${metafactory.addLibraryToClass("javax.persistence.criteria.Predicate")}
  <#local fromReference = "from${referenceClassName}">
  CriteriaBuilder cb = getEm().getCriteriaBuilder();
  CriteriaQuery<${referenceClassName}> cq = cb.createQuery(${referenceClassName}.class);
  Root<${referenceClassName}> ${fromReference} = cq.from(${referenceClassName}.class);
  Predicate allCriteria = cb.conjunction();

<#--
  Alle 1 references van modelObject moeten nu worden langsgelopen.
  Als het referenceObject zelf ook een reference heeft van het zelfde type, dan moet die worden toegevoegd aan criteria
-->
  <#local references01 = modelObject.findReferencesByMultiplicity("0..1")>
  <#local references11 = modelObject.findReferencesByMultiplicity("1..1")>
  <#local references1 = references01>
  <#if references1.addAll(references11)> <#--trick to ignore result of addAll method--></#if>

  <#local contextForEdit = "contextForEdit">
  <#local fillObjectDefined = false>
  <#list references1 as objectReference>
    <#local objectReferenceName = objectReference.name>
    <#local objectReferenceNameFU = objectReferenceName?cap_first >
    <#local objectReferenceType = objectReference.type>
    <#local objectReferenceTypeFL = objectReferenceType?uncap_first >
    <#local objectReferenceMultiplicity = objectReference.multiplicity>
    <#local objectReferenceObjectElement = modelPackage.findObjectByName(objectReferenceType)>
    <#local isEnum = objectReferenceObjectElement.getMetaData("enum")>
    <#-- Als $referenceObjectElement nu ook een reference heeft van dit type, dan moet het worden toegevoegd aan criteria -->
      <#if (referenceObjectElement.findReferenceByType(objectReferenceType))?? >

        ${metafactory.addLibraryToClass("javax.persistence.criteria.Expression")}
        <#local sameReference = referenceObjectElement.findReferenceByType(objectReferenceType)>
        <#local sameReferenceName = sameReference.name>
        <#local sameReferenceNameFU = sameReferenceName?cap_first >
        // object ${modelObjectName} has a reference of type ${objectReferenceType} with name ${objectReferenceName} and object ${referenceType} has also a reference of type ${objectReferenceType} and name ${sameReferenceName}
        if (${contextForEdit}.get${objectReferenceNameFU}() != null)
        {
          ${metafactory.addLibraryToClass("${packageName}.${referenceClassName}_")}
          <#if isEnum=="true">
            <#local equalName = "equal${sameReferenceNameFU}">
            Expression<Boolean> ${equalName} = cb.equal(${fromReference}.get(${referenceClassName}_.${objectReferenceName}), ${contextForEdit}.get${objectReferenceNameFU}());
            allCriteria = cb.and(allCriteria, ${equalName});
          <#else>
            // join on ${referenceType}
            <#local joinName = "${sameReferenceName}Join">
            <#local equalName = "equal${sameReferenceNameFU}">
            ${metafactory.addLibraryToClass("javax.persistence.criteria.Join")}
            Join<${referenceClassName}, ${objectReferenceType}> ${joinName} = ${fromReference}.join(${referenceClassName}_.${sameReferenceName});
            Expression<Boolean> ${equalName} = cb.equal(${joinName}, ${contextForEdit}.get${objectReferenceNameFU}());
            allCriteria = cb.and(allCriteria, ${equalName});
          </#if>

          //criteria.add(Restrictions.eq("${sameReferenceName}", ${contextForEdit}.get${objectReferenceNameFU}()));
        }

      </#if>

  </#list>
  cq.select(from${referenceClassName}).where(allCriteria);

  TypedQuery<${referenceClassName}> q = getEm().createQuery(cq);
  List<${referenceClassName}> ${referencePluralPropertyFL} = q.getResultList();

  return ${referencePluralPropertyFL};

</#macro>
