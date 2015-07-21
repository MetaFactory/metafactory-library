<#--stop if $currentModelPackage is null-->
<#if !(currentModelPackage)??>  ${generator.error("currentModelPackage not found in context")} </#if>

<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>

<#assign modelPackage = currentModelPackage>
<#assign modelObjectName = currentModelObject.getAttributeValue("name")>
<#assign modelObjectNameFL = generator.firstLower(modelObjectName)>

<#global comparatorPropertyName = context.getPatternPropertyValue("comparator.property", "businesskey") >

<#assign comparatorAttributes = generator.findChildrenByProperty(currentModelObject, "attribute", comparatorPropertyName)>
<#assign comparatorReferences = generator.findChildrenByProperty(currentModelObject, "reference", comparatorPropertyName)>
<#assign comparator = comparatorFactory.createElementComparator(comparatorPropertyName)>
<#assign isEnum = generator.elementContainsProperty(currentModelObject,"enum","true")>

int result;
if (o1 == null && o2 == null)
{
  result = 0;
}
else if (o1 == null && o2 != null)
{
  result = -1;
}
else if (o1 != null && o2 == null)
{
  result = 1;
}
else
{
  <#if isEnum>
    <#--enums can be compared to each other-->
    result = o1.compareTo(o2);
  <#else>
    <#--non enum types are compared by attributes and references with comparator property -->
    <#assign globalCount = 1>
    <#assign comparatorFields = comparatorAttributes>
    <#if comparatorFields.addAll(comparatorReferences)><#--trick to ignore result of addAll method--></#if>
    <#assign sortedComparatorFields = generator.sort(comparatorFields, comparator)>
    <#if sortedComparatorFields.size()==0>
      <#stop "No fields found to use in comparator. object=${modelObjectName}. Add properties <${comparatorPropertyName}>int</${comparatorPropertyName}> to attributes and references. The name of this property (${comparatorPropertyName}) can be set by a 'pattern property' with <comparator.property>property.name.to.use</comparator.property>" >
    </#if>
    <#if sortedComparatorFields.size()==1>
      <#assign only1Field = true>
    <#else>
      <#assign only1Field = false>
    </#if>
    <#--java code starts here-->
    <#foreach field in sortedComparatorFields>
      <#if globalCount &gt; 1>
        else
      </#if>
      <#-- >// field ${globalCount} = ${field.getAttributeValue("name")} -->
      <#if field.getName() == "attribute">
        <#if only1Field>
          // compare single attribute
          <#call compareSingleAttribute attributeField=field />
        <#else>
          <#call compareAttribute attributeField=field />
        </#if>
      <#elseif field.getName() == "reference">
        <#if only1Field>
          // compare single reference
          <#call compareSingleReference field />
        <#else>
          <#call compareReference referenceField=field />
        </#if>
      <#else>
        ${generator.error("Unexpected comparator element found: " + field.getElementName() + ". Only attribute of reference expected.")}
      </#if>
      <#assign globalCount = globalCount + 1>
    </#foreach>
    <#if !only1Field>
      else
      {
        result = 0;
      }
    </#if>
  </#if>
}
return result;
<#----------------------------------------------------------------------------------------------------------->

<#macro compareAttribute attributeField>
  <#if attributeField.getName() != "attribute">
    ${generator.error("Error in snippet compare: macro compareAttribute called with wrong parameter. Only attribute allowed, but name of parameter element is " + attributeField.getName())}
  </#if>
  <#---->
  <#local attributeName = attributeField.getAttributeValue("name")>
  <#local attributeType = attributeField.getAttributeValue("type")>
  <#local attributeNameFU = generator.firstUpper(attributeName)>
  <#local notnull = attributeField.getAttributeValue("notnull") ! "">
  <#if notnull == "true">
    <#local required = true>
  <#else>
    <#local required = false>
  </#if>
  <#if generator.isPrimitiveJavaType(attributeType)>
    <#local javaType = generator.getJavaType(attributeType) >
    <#if javaType == "boolean">
      <#-- boolean getters use "is" instead of "get"-->
      if (o1.is${attributeNameFU}() != o2.is${attributeNameFU}())
      {
        <#call compareSinglePrimitiveAttribute attributeName=attributeName wrapperClass="" isBooleanType=true />
      }
    <#else>
      <#local wrapperClass = generator.getJavaWrapperClass(attributeType) >
      if (o1.get${attributeNameFU}() != o2.get${attributeNameFU}())
      {
        <#call compareSinglePrimitiveAttribute attributeName=attributeName wrapperClass=wrapperClass isBooleanType=false />
      }
    </#if>
  <#else>
    <#--handle primitivetypes other than objects-->
    <#if required == true>
      if (!o1.get${attributeNameFU}().equals(o2.get${attributeNameFU}()))
      {
        <#call compareSingleNotPrimitiveAttribute attributeName=attributeName attributeType=attributeType />
      }
    <#else>
      if (!o1.get${attributeNameFU}().equals(o2.get${attributeNameFU}()))
      {
        <#call compareSingleNotPrimitiveAttribute attributeName=attributeName attributeType=attributeType />
      }
    </#if>
  </#if>
</#macro>
<#----------------------------------------------------------------------------------------------------------->
<#macro compareSingleAttribute attributeField>
  <#if attributeField.getName() != "attribute">
    ${generator.error("Error in snippet compare: macro compareSingleAttribute called with wrong parameter. Only attribute allowed, but name of parameter element is " + attributeField.getName())}
  </#if>
  <#---->
  <#local attributeName = attributeField.getAttributeValue("name")>
  <#local attributeType = attributeField.getAttributeValue("type")>
  <#if generator.isPrimitiveJavaType(attributeType)>
    <#local javaType = generator.getJavaType(attributeType) >
    <#if javaType == "boolean">
      <#call compareSinglePrimitiveAttribute attributeName=attributeName wrapperClass="" isBooleanType=true />
    <#else>
      <#local wrapperClass = generator.getJavaWrapperClass(attributeType) >
      <#call compareSinglePrimitiveAttribute attributeName=attributeName wrapperClass=wrapperClass isBooleanType=false />
    </#if>
  <#else>
    <#call compareSingleNotPrimitiveAttribute attributeName=attributeName attributeType=attributeType />
  </#if>

</#macro>
<#----------------------------------------------------------------------------------------------------------->

<#macro compareSinglePrimitiveAttribute attributeName wrapperClass isBooleanType>
  <#if isBooleanType>
    if (o1.is${attributeName?cap_first}())
    {
      result = 1;
    }
    else
    {
      result = -1;
    }
  <#else>
    result = new ${wrapperClass}(o1.get${attributeName?cap_first}()).compareTo(new ${wrapperClass}(o2.get${attributeName?cap_first}()));
  </#if>
</#macro>

<#----------------------------------------------------------------------------------------------------------->

<#macro compareSingleNotPrimitiveAttribute attributeName attributeType>
  result = o1.get${attributeName?cap_first}().compareTo(o2.get${attributeName?cap_first}());
</#macro>

<#----------------------------------------------------------------------------------------------------------->

<#macro compareReference referenceField>
  <#if referenceField.getName() != "reference">
    ${generator.error("Error in snippet compare: macro compareReference called with wrong first parameter. Only reference allowed, but name of parameter element is " + referenceField.getName())}
  </#if>
  <#---->
  <#local referenceName = referenceField.getAttributeValue("name")>
  <#local referenceType = referenceField.getAttributeValue("type")>
  if (!o1.get${referenceName?cap_first}().equals(o2.get${referenceName?cap_first}()))
  {
    <#call compareSingleReference referenceField />
  }
</#macro>

<#----------------------------------------------------------------------------------------------------------->

<#macro compareSingleReference referenceField>
  <#local referenceName = referenceField.getAttributeValue("name")>
  <#local referenceType = referenceField.getAttributeValue("type")>
  <#local referenceObjectElement = generator.findChildByAttribute(modelPackage, "object", "name", referenceType)>
  <#local isEnum = generator.elementContainsProperty(referenceObjectElement,"enum","true")>
  <#if isEnum>
    <#--enums can be compared to each other-->
    result = o1.get${referenceName?cap_first}().compareTo(o2.get${referenceName?cap_first}());
  <#else>
    result = new ${referenceType}Comparator().compare(o1.get${referenceName?cap_first}(), o2.get${referenceName?cap_first}());
  </#if>
</#macro>
