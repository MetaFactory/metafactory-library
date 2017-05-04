<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>

<#--stop if $modelPackage is null-->
<#if !(modelPackage)??>  ${metafactory.error("modelPackage not found in context")} </#if>

<#--stop if $var0 is null-->
<#if !(var0)??>  ${metafactory.error("var0 not found in context")} </#if>


<#assign modelObjectName = modelObject.name>
<#assign modelObjectNameFL = modelObjectName?uncap_first>
<#assign modelObjectNamePL = modelObject.getMetaData("name.plural", "${modelObjectName}s")>
<#assign modelObjectNamePLFL = modelObjectNamePL?uncap_first>
<#assign propertyName = "dao.finder.list.key.${var0}">

<#-- Get all the attributes and references of current model object which must be used in this finder method => which has property ${propertyName}-->
<#assign finderAttributes = modelObject.findAttributesByMetaData("${propertyName}" )>
<#assign finderReferences = modelObject.findReferencesByMetaData("${propertyName}" )>
<#assign all = finderAttributes + finderReferences>

<#-- packageName contains the name of the package of the pojo's -->
<#assign packageName = metafactory.evaluateExpression("${'$'}{pattern.property.model.implementation.package}", context) >

<#-- className contains the name of the class of a pojo which is created foreach model object -->
<#assign className = metafactory.evaluateExpression("${'$'}{pattern.property.model.implementation.class}", context) >
${metafactory.addLibraryToClass("javax.persistence.criteria.Expression")}
${metafactory.addLibraryToClass("javax.persistence.criteria.CriteriaBuilder")}
${metafactory.addLibraryToClass("javax.persistence.criteria.CriteriaQuery")}
${metafactory.addLibraryToClass("javax.persistence.criteria.Predicate")}
${metafactory.addLibraryToClass("javax.persistence.criteria.Root")}
${metafactory.addLibraryToClass("javax.persistence.TypedQuery")}

CriteriaBuilder cb = getEm().getCriteriaBuilder();
CriteriaQuery<${className}> cq = cb.createQuery(${className}.class);

Root<${className}> from${className} = cq.from(${className}.class);

Predicate allCriteria = cb.conjunction();

<#list all as finderItem>
  <#assign itemName = finderItem.getName()>
  <#if itemName == "attribute">
    <@useAttributeForFinder finderItem  />
  <#elseif itemName == "reference">
    <@useReferenceForFinder finderItem  />
  <#else>
    <#stop "Invalid item found in java/cdi/beans/findPluralByFields.ftl. item=" + itemName + ", model=" + modelObjectName + ", propertyName=" + propertyName >
  </#if>
</#list>

cq.select(from${className}).where(allCriteria);

TypedQuery<${className}> q = getEm().createQuery(cq);
List<${className}> result = q.getResultList();

return result;
<#------------------------------------------------------------------------------------------------------>
<#macro useAttributeForFinder attribute>
  <#local eName = attribute.getName()>
  <#if eName != "attribute">
    <#stop "macro useAttributeForFinder called with wrong argument. first parameter needs to be a attribute element, but is a " + eName + " instead. object=" + modelObjectName >
  </#if>
  <#local attributeName = attribute.name>
  <#local attributeType = attribute.type>
  <#local attributeNameFU = attributeName?cap_first >
  Expression<Boolean> equal${attributeNameFU} = cb.equal(from${className}.get(${className}_.${attributeName}), ${attributeName});
  allCriteria = cb.and(allCriteria, equal${attributeNameFU});

</#macro>
<#------------------------------------------------------------------------------------------------------>
<#macro useReferenceForFinder reference>
  <#local eName = reference.getName()>
  <#if eName != "reference">
    <#stop "macro useReferenceForFinder called with wrong argument. first parameter needs to be a reference element, but is a " + eName + " instead. object=" + modelObjectName >
  </#if>
  <#local referenceName = reference.name>
  <#local referenceType = reference.type>
  <#local multiplicity = reference.multiplicity>
  <#local referenceNameAU = referenceName?upper_case >
  <#local referenceNameFU = referenceName?cap_first >
  <#local referenceObjectElement = modelPackage.findObjectByName(referenceType)>
  <#local isEnum = referenceObjectElement.getMetaData("enum")>
  <#-- referenceTypeName contains the name of the java type (class) which corresponds to model reference of type ${referenceType}, right? -->
  ${context.setModelReference(reference)} <#-- FIXME Marnix 2011-12-23: New functionality must be created to prevent tricks like this.
  This link is needed to make the line below work -->
  <#local referenceTypeName = metafactory.evaluateExpression("${'$'}{pattern.property.model.implementation.reference}", context) >

  <#if multiplicity == "0..1" || multiplicity == "1..1">
    <#-- TODO Marnix 2011-12-23: Ik weet eigenlijk niet eens zeker of het wel per s� een 0..1 of 1..1 reference moet zijn of dat 0..n ook zou kunnen -->
    <#if isEnum=="true">
      Expression<Boolean> equal${referenceNameFU} = cb.equal(from${className}.get(${className}_.${referenceName}), ${referenceName});
    <#else>
      // join on ${referenceType}
      ${metafactory.addLibraryToClass("${packageName}.${className}_")}
      ${metafactory.addLibraryToClass("javax.persistence.criteria.Join")}
      Join<${className}, ${referenceTypeName}> ${referenceName}Join = from${className}.join(${className}_.${referenceName});
      Expression<Boolean> equal${referenceNameFU} = cb.equal(${referenceName}Join, ${referenceName});
    </#if>
    allCriteria = cb.and(allCriteria, equal${referenceNameFU});

  <#else>
    <#stop "A reference with wrong multiplicity (${multiplicity}) found in label.ftl. reference=" + referenceName + ", model=" + modelObjectName + ". Only 0..1 or 1..1 can be used." >
  </#if>

</#macro>
<#------------------------------------------------------------------------------------------------------>
