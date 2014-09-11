<#--stop if $currentModelPackage is null-->
<#if !(currentModelPackage)??>  ${generator.error("currentModelPackage not found in context")} </#if>
<#---->
<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>
<#---->
<#--stop if $currentModelReference is null-->
<#if !(currentModelReference)??>  <#stop "currentModelReference not found in context" ></#if>
<#---->
<#assign modelObjectName = currentModelObject.getAttributeValue("name")>
<#assign modelObjectNameFL = modelObjectName?uncap_first>
<#assign modelObjectNamePL = generator.getElementProperty(currentModelObject, "name.plural", "${modelObjectName}s")>
<#assign modelObjectNamePLFL = modelObjectNamePL?uncap_first>

<#assign referenceName = currentModelReference.getAttributeValue("name")>
<#assign referenceNameFU = referenceName?cap_first >
<#assign referenceType = currentModelReference.getAttributeValue("type")>
<#assign multiplicity = currentModelReference.getAttributeValue("multiplicity")>
<#assign referenceClassName = generator.evaluateExpression("${'$'}{pattern.property.model.implementation.reference}", context) >
<#assign referenceObjectElement = generator.findChildByAttribute(currentModelPackage, "object" , "name", referenceType)>
<#assign referencePluralProperty = generator.getElementProperty(referenceObjectElement,"name.plural")>
<#assign referencePluralPropertyFL = referencePluralProperty?uncap_first >

<#assign packageName = generator.evaluateExpression("${'$'}{pattern.property.model.implementation.package}", context) >

<#assign isEnum = generator.getElementProperty(referenceObjectElement, "enum")>

<#assign projectSpecificSearchProperty = generator.getElementProperty(currentModelReference, "projectspecific.fillComboForEdit", "false")>
<#assign projectSpecificSearch = generator.elementContainsProperty(currentModelReference, "projectspecific.fillComboForEdit", "true")>
<#if projectSpecificSearch >
  <#assign body>
    <@createBodyUsingJPA2 />
  </#assign>
  ${generator.evaluateFreeMarkerSnippet("projectspecific.java.cdi.beans.fillReferenceTypeComboForEdit", body)}
<#else>
  <@createBodyUsingJPA2 />
</#if>

<#------------------------------------------------------------------------------------------------------>
<#macro createBodyUsingJPA2 >
<#--
  ${generator.addLibraryToClass("java.util.ArrayList")}
  return new ArrayList<${referenceClassName}>();
-->
  ${generator.addLibraryToClass("javax.persistence.criteria.CriteriaBuilder")}
  ${generator.addLibraryToClass("javax.persistence.criteria.CriteriaQuery")}
  ${generator.addLibraryToClass("javax.persistence.criteria.Root")}
  ${generator.addLibraryToClass("javax.persistence.TypedQuery")}
  ${generator.addLibraryToClass("javax.persistence.criteria.Predicate")}
  <#local fromReference = "from${referenceClassName}">
  CriteriaBuilder cb = getEm().getCriteriaBuilder();
  CriteriaQuery<${referenceClassName}> cq = cb.createQuery(${referenceClassName}.class);
  Root<${referenceClassName}> ${fromReference} = cq.from(${referenceClassName}.class);
  Predicate allCriteria = cb.conjunction();

<#--
  Alle 1 references van modelObject moeten nu worden langsgelopen.
  Als het referenceObject zelf ook een reference heeft van het zelfde type, dan moet die worden toegevoegd aan criteria
-->
  <#local references01 = generator.findChildrenByAttribute(currentModelObject, "reference" , "multiplicity", "0..1")>
  <#local references11 = generator.findChildrenByAttribute(currentModelObject, "reference" , "multiplicity", "1..1")>
  <#local references1 = references01>
  <#if references1.addAll(references11)> <#--trick to ignore result of addAll method--></#if>

  <#local contextForEdit = "contextForEdit">
  <#local fillObjectDefined = false>
  <#list references1 as objectReference>
    <#local objectReferenceName = objectReference.getAttributeValue("name")>
    <#local objectReferenceNameFU = objectReferenceName?cap_first >
    <#local objectReferenceType = objectReference.getAttributeValue("type")>
    <#local objectReferenceTypeFL = objectReferenceType?uncap_first >
    <#local objectReferenceMultiplicity = objectReference.getAttributeValue("multiplicity")>
    <#local objectReferenceObjectElement = generator.findChildByAttribute(currentModelPackage, "object" , "name", objectReferenceType)>
    <#local isEnum = generator.getElementProperty(objectReferenceObjectElement, "enum")>
    <#-- Als $referenceObjectElement nu ook een reference heeft van dit type, dan moet het worden toegevoegd aan criteria -->
      <#if (generator.findChildByAttribute(referenceObjectElement, "reference", "type", objectReferenceType))?? >

        ${generator.addLibraryToClass("javax.persistence.criteria.Expression")}
        <#local sameReference = generator.findChildByAttribute(referenceObjectElement, "reference", "type", objectReferenceType)>
        <#local sameReferenceName = sameReference.getAttributeValue("name")>
        <#local sameReferenceNameFU = sameReferenceName?cap_first >
        // object ${modelObjectName} has a reference of type ${objectReferenceType} with name ${objectReferenceName} and object ${referenceType} has also a reference of type ${objectReferenceType} and name ${sameReferenceName}
        if (${contextForEdit}.get${objectReferenceNameFU}() != null)
        {
          ${generator.addLibraryToClass("${packageName}.${referenceClassName}_")}
          <#if isEnum=="true">
            <#local equalName = "equal${sameReferenceNameFU}">
            Expression<Boolean> ${equalName} = cb.equal(${fromReference}.get(${referenceClassName}_.${objectReferenceName}), ${contextForEdit}.get${objectReferenceNameFU}());
            allCriteria = cb.and(allCriteria, ${equalName});
          <#else>
            // join on ${referenceType}
            <#local joinName = "${sameReferenceName}Join">
            <#local equalName = "equal${sameReferenceNameFU}">
            ${generator.addLibraryToClass("javax.persistence.criteria.Join")}
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