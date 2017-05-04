<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>
<#assign modelObjectName = modelObject.name>
<#assign modelObjectNameFL = modelObjectName?uncap_first>
<#--Get all attributes with property -->
<#assign defaultAttributes = modelObject.findAttributesByMetaData("entity.default.value")>
<#list defaultAttributes as attribute>
  <#assign attributeName = attribute.name>
  <#assign attributeType = attribute.type>
  <#assign attributeNameFU = attributeName?cap_first>
  <#assign javaType = metafactory.getJavaType(attributeType)>
  this.${attributeName} = ${attribute.getMetaData("entity.default.value")};
</#list>
