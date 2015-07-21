<#--stop if $currentModelPackage is null-->
<#if !(currentModelPackage)??>  <#stop "currentModelPackage not found in context" ></#if>

<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>

<#assign modelPackage = currentModelPackage>
<#assign modelObjectName = currentModelObject.getAttributeValue("name")>
<#assign modelObjectNameFL = modelObjectName?uncap_first >
<#assign labelAttributes = generator.findChildrenByProperty(currentModelObject, "attribute", "label")>
<#assign labelReferences = generator.findChildrenByProperty(currentModelObject, "reference", "label")>
<#assign all = labelAttributes + labelReferences>

<#--comparator sorts elements by value of the specified property-->
<#assign comparator = comparatorFactory.createElementComparator("label" )>
<#assign sortedItems = generator.sort(all, comparator)>
<#if sortedItems.size() == 0 >
  <#--No properties found ==> use toString -->
  // TODO add label properties
  return this.toString();
<#else>
  <#--Normal behaviour  -->
  StringBuilder result = new StringBuilder();
  <#list sortedItems as labelItem>
      <#assign itemName = labelItem.getName()>
      <#if itemName == "attribute">
        <@useAttributeForLabel labelItem  />
      <#elseif itemName == "reference">
        <@useReferenceForLabel labelItem  />
      <#else>
        <#stop "Invalid item found in label.ftl. item=" + itemName + ", model=" + modelObjectName >
      </#if>
  </#list>
  return result.toString().trim();
</#if>

<#------------------------------------------------------------------------------------------------------>

<#macro useAttributeForLabel attribute>
  <#local eName = attribute.getName()>
  <#if eName != "attribute">
    <#stop "macro useAttributeForLabel called with wrong argument. first parameter needs to be a attribute element, but is a " + eName + " instead. object=" + modelObjectName >
  </#if>
  <#assign attributeName = attribute.getAttributeValue("name")>
  <#assign attributeType = attribute.getAttributeValue("type")>
  <#if (generator.isPrimitiveJavaType(attributeType))> <#-- Maybe check type (int, long, short etc)-->
    result.append(${generator.getJavaWrapperClass(attributeType)}(${attributeName}).valueOf(${attributeName}) + " ");
  <#else>
    <#--handle primitivetypes other than objects-->
    if (${attributeName} != null)
    {
      result.append(${attributeName} + " ");
    }
  </#if>

</#macro>

<#------------------------------------------------------------------------------------------------------>

<#macro useReferenceForLabel reference>
  <#assign eName = reference.getName()>
  <#if eName != "reference">
    <#stop "macro useReferenceForLabel called with wrong argument. first parameter needs to be a reference element, but is a " + eName + " instead. object=" + modelObjectName >
  </#if>
  <#assign referenceName = reference.getAttributeValue("name")>
  <#assign referenceType = reference.getAttributeValue("type")>
  <#assign multiplicity = reference.getAttributeValue("multiplicity")>
  <#if multiplicity == "0..1" || multiplicity == "1..1">
    if (${referenceName} != null)
    {
      result.append(${referenceName}.getLabel() + " ");
    }
  <#else>
    <#stop "A reference with wrong multiplicity (${multiplicity}) found in label.ftl. reference=" + referenceName + ", model=" + modelObjectName + ". Only 0..1 or 1..1 can be used." >
  </#if>

</#macro>

<#------------------------------------------------------------------------------------------------------>
