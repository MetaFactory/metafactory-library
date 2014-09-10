<#include "/include/model/findBusinessKeys.ftl" >

<#--stop if $operationPattern is null-->
<#if !(operationPattern)??>  <#stop "operationPattern not found in context => Is this snippet used to create a method?" ></#if>

<#assign compareObject = modelObjectNameFL >
<#assign apicomment = operationPattern.getChild("apicomment", nsPattern) >
<#assign apicommentText = "Fields used as businesskey:" >

<#if sortedBusinessKeyFields.size() == 0 >
    // FIXME: no businesskey fields defined
    return false;
<#else>
  <#--Normal behaviour -->
  boolean result = true;
  <#--
    Find out if all business keys are not-primitive types. If that's the case additional code must be created to prevent
    all business keys are null
  -->
  <#assign noPrimitiveBusinessKeys = true >
  <#list sortedBusinessKeyFields as field>
    <#if field.getName()=="attribute" >
      <#assign attributeType = field.getAttributeValue("type") >
      <#if generator.isPrimitiveJavaType(attributeType) >
        <#assign noPrimitiveBusinessKeys = false >
      </#if>
    </#if>
  </#list>
  <#if noPrimitiveBusinessKeys == true >
    <@testIfAllBusinessKeysAreNull sortedBusinessKeyFields />
    else {
  </#if>
  <#compress>
  <#list sortedBusinessKeyFields as field>
    <#if (field_index > 0) > else </#if>
    <#if field.getName() == "attribute" >
      <#assign attributeName = field.getAttributeValue( "name")>
      <#assign attributeType = field.getAttributeValue( "type")>
      <#assign attributeNameFU = attributeName?cap_first>
      <#if generator.isPrimitiveJavaType(attributeType) >
        <#if generator.getJavaType(attributeType) == "boolean" >
          if (this.is${attributeNameFU}() != ${compareObject}.is${attributeNameFU}()) {
            result = false;
          }
        <#else>
          if (this.get${attributeNameFU}() != ${compareObject}.get${attributeNameFU}()) {
            result = false;
          }
        </#if>
      <#else> <#--not a primitive attribute -->
        if (this.get${attributeNameFU}() != null && ! this.get${attributeNameFU}().equals(${compareObject}.get${attributeNameFU}())) {
          result = false;
        }
      </#if>
    <#elseif field.getName()== "reference" >
      <#assign referenceName = field.getAttributeValue( "name")>
      <#assign referenceType = field.getAttributeValue( "type")>
      <#assign referenceNameFU = referenceName?cap_first>
      if (this.get${referenceNameFU}() != null && ! this.get${referenceNameFU}().equals(${compareObject}.get${referenceNameFU}())) {
        result = false;
      }
    <#else>
      <#stop "Unexpected businessKey element found: $field.getName(). Only attribute or reference expected.">
    </#if>
    <#--Add this field to the apicomment -->
    <#assign previousComment = apicommentText >
    <#assign counter = field_index + 1 >
    <#assign apicommentText = " ${previousComment} ${counter}) ${field.getAttributeValue('name')}" >
  </#list>
  </#compress>
  <#if noPrimitiveBusinessKeys == true >
    }
  </#if>
  return result;
</#if>
<#assign apicommentText = "${apicommentText}." >
${generatedOperation.setApiComment(apicommentText)}

<#------------------------------------------------------------------------------------------------------>
<#macro testIfAllBusinessKeysAreNull bkList>
  <#compress>
  // If all business keys are null, return false
  if (
    <#list bkList as field>
      <#if (field_index > 0) > && </#if>
      <#if field.getName() == "attribute" >
        <#assign attributeName = field.getAttributeValue( "name")>
        <#assign attributeNameFU = attributeName?cap_first>
        this.get${attributeNameFU}() == null
      <#elseif field.getName()== "reference" >
        <#assign referenceName = field.getAttributeValue( "name")>
        <#assign referenceNameFU = referenceName?cap_first>
        this.get${referenceNameFU}() == null
      <#else>
        <#stop "Unexpected businessKey element found: $field.getName(). Only attribute or reference expected.">
      </#if>
    </#list>
      )
  {
    result = false;
  }
  </#compress>
</#macro>
<#------------------------------------------------------------------------------------------------------>
