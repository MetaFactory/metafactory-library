<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>

<#--stop if $currentModelAttribute is null-->
<#if !(currentModelAttribute)??>  <#stop "currentModelAttribute not found in context" ></#if>

<#assign modelObjectName = currentModelObject.getAttributeValue("name")>
<#assign modelObjectNameFL = modelObjectName?uncap_first>
<#assign modelObjectNamePL = generator.getElementProperty(currentModelObject, "name.plural", "${modelObjectName}s")>
<#assign modelObjectNamePLFL = modelObjectNamePL?uncap_first>

<#assign attributeName = currentModelAttribute.getAttributeValue("name")>
<#assign attributeType = currentModelAttribute.getAttributeValue("type")>
<#assign attributeNameFU = attributeName?cap_first>
<#assign javaType = generator.getJavaType(attributeType)>

<#assign apiComment = generator.getElementProperty(currentModelAttribute,"model.apicomment")>
${apiComment}