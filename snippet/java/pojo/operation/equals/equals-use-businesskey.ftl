<#include "/include/model/findBusinessKeys.ftl" >

<#--stop if $operationPattern is null-->
<#if !(operationPattern)??>  <#stop "operationPattern not found in context => Is this snippet used to create a method?" ></#if>

<#assign compareObject = modelObjectNameFL >
<#assign apicomment = operationPattern.getExpressionForApiComment() >
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
    <#if field.isModelAttribute() >
      <#assign attributeType = field.toModelAttribute().type >
      <#if metafactory.isPrimitiveJavaType(attributeType) >
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
    <#if field.isModelAttribute() >
      <#assign attribute = field.toModelAttribute() />
      <#assign attributeName = attribute.name>
      <#assign attributeType = attribute.type>
      <#assign attributeNameFU = attributeName?cap_first>
      <#if metafactory.isPrimitiveJavaType(attributeType) >
        <#if metafactory.getJavaType(attributeType) == "boolean" >
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
    <#elseif field.isModelReference() >
      <#assign reference = field.toModelReference() />
      <#assign referenceName = reference.name>
      <#assign referenceType = reference.type>
      <#assign referenceNameFU = referenceName?cap_first>
      if (this.get${referenceNameFU}() != null && ! this.get${referenceNameFU}().equals(${compareObject}.get${referenceNameFU}())) {
        result = false;
      }
    <#else>
      <#stop "Unexpected businessKey element found: $field.kind. Only attribute or reference expected.">
    </#if>
    <#--Add this field to the apicomment -->
    <#assign previousComment = apicommentText >
    <#assign counter = field_index + 1 >
    <#assign apicommentText = " ${previousComment} ${counter}) ${field.name}" >
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
      <#if field.kind == "attribute" >
        <#assign attributeName = field.name>
        <#assign attributeNameFU = attributeName?cap_first>
        this.get${attributeNameFU}() == null
      <#elseif field.kind== "reference" >
        <#assign referenceName = field.name>
        <#assign referenceNameFU = referenceName?cap_first>
        this.get${referenceNameFU}() == null
      <#else>
        <#stop "Unexpected businessKey element found: $field.kind. Only attribute or reference expected.">
      </#if>
    </#list>
      )
  {
    result = false;
  }
  </#compress>
</#macro>
<#------------------------------------------------------------------------------------------------------>
