<#include "/include/model/findBusinessKeys.ftl" >

<#--stop if $operationPattern is null-->
<#if !(operationPattern)??>  <#stop "operationPattern not found in context => Is this snippet used to create a method?" ></#if>

<#assign isEnum = modelObject.getMetaData("enum")>
<#if (isEnum=="true") >
  return this.name() + "(" + this.ordinal() + ")";
<#else>
  <#assign apicommentText = "toString based on businesskeys:" >

  StringBuilder result = new StringBuilder("${modelObjectName}: ");

  <#list sortedBusinessKeyFields as field>
    <#if (field_index > 0) > result.append(", "); </#if>
      <#if field.isModelAttribute() >
      <#assign attribute = field.toModelAttribute() />
      <#assign attributeName = attribute.name>
      <#assign attributeType = attribute.type>
      <#assign attributeNameFU = attributeName?cap_first>
      <#if metafactory.isPrimitiveJavaType(attributeType) >
        result.append("${attributeName}=" + ${attributeName});
      <#else> <#--not a primitive attribute -->
        if (${attributeName} != null)
        {
            result.append("${attributeName}=" + ${attributeName}.toString());
        }
        else
        {
            result.append("${attributeName}=null");
        }
      </#if>
    <#elseif field.isModelReference() >
      <#assign reference = field.toModelReference() />
      <#assign referenceName = reference.name>
      <#assign referenceType = reference.type>
      <#assign referenceNameFU = referenceName?cap_first>
      if (${referenceName} != null)
      {
        result.append("${referenceName}=" + ${referenceName}.toString());
      }
      else
      {
        result.append("${referenceName}=null");
      }
    <#else>
      <#stop "Unexpected businessKey element found: ${field.kind}. Only attribute or reference expected.">
    </#if>
    <#--Add this field to the apicomment -->
    <#assign previousComment = apicommentText >
    <#assign counter = field_index + 1 >
    <#assign apicommentText = " ${previousComment} ${counter}) ${field.name}" >
  </#list>
  return result.toString();

  <#-- Now set the apicomment for the created toString method -->
  <#assign apicommentText = "${apicommentText}." >
  ${generatedOperation.setApiComment(apicommentText)}
</#if>
