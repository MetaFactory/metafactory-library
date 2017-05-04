<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>

<#--stop if $modelAttribute is null-->
<#if !(modelAttribute)??>  <#stop "modelAttribute not found in context" ></#if>

<#assign modelObjectName = modelObject.name>
<#assign modelObjectNameFL = modelObjectName?uncap_first>
<#assign modelObjectNamePL = modelObject.getMetaData("name.plural", "${modelObjectName}s")>
<#assign modelObjectNamePLFL = modelObjectNamePL?uncap_first>

<#assign attributeName = modelAttribute.name>
<#assign attributeType = modelAttribute.type>
<#assign attributeNameFU = attributeName?cap_first>
<#assign javaType = metafactory.getJavaType(attributeType)>

<#assign apiComment = modelAttribute.getMetaData("model.apicomment")>
${apiComment}
