<#--stop if $currentModelAttribute is null-->
<#if !(currentModelAttribute)??>  <#stop "currentModelAttribute not found in context" ></#if>

<#assign attributeName = currentModelAttribute.getAttributeValue("name") >
<#assign attributeType = currentModelAttribute.getAttributeValue("type") >
<#assign attributeNameFU = attributeName?cap_first >

<#-- The only additional thing this setter will do is convert a empty String to null type of attribute is String -->
<#if (attributeType=="String" || attributeType=="text") >
  if (${attributeName}==null || ${attributeName}.trim().length()==0)
  {
    this.${attributeName} = null;
  }
  else
  {
    this.${attributeName} = ${attributeName};
  }
<#else>
  this.${attributeName} = ${attributeName};
</#if>
