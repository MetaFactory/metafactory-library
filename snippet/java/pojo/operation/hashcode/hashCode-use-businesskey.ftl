<#include "/include/model/findBusinessKeys.ftl" >

<#--stop if $operationPattern is null-->
<#if !(operationPattern)??>  <#stop "operationPattern not found in context => Is this snippet used to create a method?" ></#if>

<#assign apicomment = operationPattern.getChild("apicomment", nsPattern) >
<#assign apicommentText = "Fields used as businesskey:" >

int result;
<#if (businessKeyFields.size()==0) >
  // FIXME: no businesskey fields defined
  result = super.hashCode();
<#else>
  result=14;

  <#list businessKeyFields as field>
    <#if (field.kind=="attribute") >
        <#assign attributeName = field.name >
        <#assign attributeType = field.type >
        <#assign attributeNameFU = metafactory.firstUpper(attributeName) >
        <#if (metafactory.isPrimitiveJavaType(attributeType)) >
          <#if (attributeType == "bool" || attributeType == "boolean") >
            result = 29*result + Boolean.valueOf(${attributeName}).hashCode(); <#-- prevents a PMD error -->
          <#else>
            result = 29*result + new ${metafactory.getJavaWrapperClass(attributeType)}(${attributeName}).hashCode();
          </#if>
        <#else>
          <#-- handle primitivetypes other than objects -->
          if (${attributeName} != null) {
            result = 29*result + this.get${metafactory.firstUpper(attributeName)}().hashCode();
          }
        </#if>
    <#elseif (field.kind=="reference") >
        <#assign referenceName = field.name >
        <#assign referenceType = field.type >
        <#assign referenceNameFU = referenceName?cap_first >
        if (${referenceName} != null) {
          result = 17*result + ${referenceName}.hashCode();
        }
    <#else>
      <#stop "Unexpected businessKey element found: ${field.kind}. Only attribute of reference expected." >
    </#if>
    <#--Add this field to the apicomment -->
    <#assign previousComment = apicommentText >
    <#assign counter = field_index + 1 >
    <#assign apicommentText = " ${previousComment} ${counter}) ${field.name}" >
  </#list>
  <#assign apicommentText = "${apicommentText}." >
  ${generatedOperation.setApiComment(apicommentText)}
</#if>
return result;
