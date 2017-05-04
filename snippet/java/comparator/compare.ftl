<#--stop if $modelPackage is null-->
<#if !(modelPackage)??>  ${metafactory.error("modelPackage not found in context")} </#if>
<#---->
<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>
<#---->

<#assign modelObjectName = modelObject.name>
<#assign modelObjectNameFL = metafactory.firstLower(modelObjectName)>

<#global comparatorPropertyName = context.getPatternPropertyValue("comparator.property", "businesskey") >

<#assign comparatorAttributes = modelObject.findAttributesByMetaData(comparatorPropertyName)>
<#assign comparatorReferences = modelObject.findReferencesByMetaData(comparatorPropertyName)>
<#assign comparator = comparatorFactory.createMetaDataComparator(comparatorPropertyName)>
<#assign isEnum = modelObject.hasMetaData("enum", "true")>

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
    <#assign sortedComparatorFields = metafactory.sort(comparatorFields, comparator)>
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
      <#-- >// field ${globalCount} = ${field.name} -->
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
        ${metafactory.error("Unexpected comparator element found: " + field.getElementName() + ". Only attribute of reference expected.")}
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
    ${metafactory.error("Error in snippet compare: macro compareAttribute called with wrong parameter. Only attribute allowed, but name of parameter element is " + attributeField.getName())}
  </#if>
  <#---->
  <#local attributeName = attributeField.name>
  <#local attributeType = attributeField.type>
  <#local attributeNameFU = metafactory.firstUpper(attributeName)>
  <#local notnull = attributeField.notnull ! "">
  <#if notnull == "true">
    <#local required = true>
  <#else>
    <#local required = false>
  </#if>
  <#if metafactory.isPrimitiveJavaType(attributeType)>
    <#local javaType = metafactory.getJavaType(attributeType) >
    <#if javaType == "boolean">
      <#-- boolean getters use "is" instead of "get"-->
      if (o1.is${attributeNameFU}() != o2.is${attributeNameFU}())
      {
        <#call compareSinglePrimitiveAttribute attributeName=attributeName wrapperClass="" isBooleanType=true />
      }
    <#elseif javaType=="int" || javaType=="long">
      if (o1.get${attributeNameFU}() != o2.get${attributeNameFU}())
      {
        result = o2.get${attributeNameFU}() - o1.get${attributeNameFU}()
      }
    <#else>
      <#local wrapperClass = metafactory.getJavaWrapperClass(attributeType) >
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
      // ${attributeName} is not required, so check also null values
      if (o1.get${attributeNameFU}() == null && o2.get${attributeNameFU}() != null)
      {
        result = -1;
      }
      else if (o1.get${attributeNameFU}() != null && o2.get${attributeNameFU}() == null)
      {
        result = 1;
      }
      else if (o1.get${attributeNameFU}() != null && o2.get${attributeNameFU}() != null  && !o1.get${attributeNameFU}().equals(o2.get${attributeNameFU}()))
      {
        <#call compareSingleNotPrimitiveAttribute attributeName attributeType />
      }
    </#if>
  </#if>
</#macro>

<#----------------------------------------------------------------------------------------------------------->

<#macro compareSingleAttribute attributeField>
  <#if attributeField.getName() != "attribute">
    ${metafactory.error("Error in snippet compare: macro compareSingleAttribute called with wrong parameter. Only attribute allowed, but name of parameter element is " + attributeField.getName())}
  </#if>

  <#local attributeName = attributeField.name>
  <#local attributeType = attributeField.type>
  <#if metafactory.isPrimitiveJavaType(attributeType)>
    <#local javaType = metafactory.getJavaType(attributeType) >
    <#if javaType == "boolean">
      <#call compareSinglePrimitiveAttribute attributeName=attributeName wrapperClass="" isBooleanType=true />
    <#else>
      <#local wrapperClass = metafactory.getJavaWrapperClass(attributeType) >
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
    ${metafactory.error("Error in snippet compare: macro compareReference called with wrong first parameter. Only reference allowed, but name of parameter element is " + referenceField.getName())}
  </#if>

  <#local referenceName = referenceField.name>
  <#local referenceType = referenceField.type>
  if (!o1.get${referenceName?cap_first}().equals(o2.get${referenceName?cap_first}()))
  {
    <#call compareSingleReference referenceField />
  }
</#macro>

<#----------------------------------------------------------------------------------------------------------->

<#macro compareSingleReference referenceField>
  <#local referenceName = referenceField.name>
  <#local referenceType = referenceField.type>
  <#local referenceObjectElement = modelPackage.findObjectByName(referenceType)>
  <#local isEnum = referenceObjectElement.hasMetaData("enum", "true")>
  <#if isEnum>
    <#--enums can be compared to each other-->
    result = o1.get${referenceName?cap_first}().compareTo(o2.get${referenceName?cap_first}());
  <#else>
    result = new ${referenceType}Comparator().compare(o1.get${referenceName?cap_first}(), o2.get${referenceName?cap_first}());
  </#if>
</#macro>
