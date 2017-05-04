<#--stop if $modelAttribute is null-->
<#if !(modelAttribute)??>  <#stop "modelAttribute not found in context" ></#if>

<#assign attributeName = modelAttribute.name >
<#assign attributeType = modelAttribute.type >
<#assign attributeNameFU = attributeName?cap_first >
<#assign debugPojo = context.getPatternPropertyValue("debug.pojo","false") >
<#if (debugPojo=="true") >
  LOG.info("set${attributeNameFU}({})", ${attributeName});
</#if>
<#-- The only additional thing this setter will do is convert a empty String to null type of attribute is String -->
<#--
  ${metafactory.addLibraryToClass("org.apache.commons.lang.StringUtils")}
  if (StringUtils.isBlank(${attributeName}))
-->
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
<#--
  this.${attributeName} = ${attributeName};
-->
