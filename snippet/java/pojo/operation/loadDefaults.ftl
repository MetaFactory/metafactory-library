<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>
<#assign modelObjectName = currentModelObject.getAttributeValue("name")>
<#assign modelObjectNameFL = modelObjectName?uncap_first>
<#--Get all attributes with property -->
<#assign defaultAttributes = generator.findChildrenByProperty(currentModelObject, "attribute", "entity.default.value")>
<#list defaultAttributes as attribute>
  <#assign attributeName = attribute.getAttributeValue("name")>
  <#assign attributeType = attribute.getAttributeValue("type")>
  <#assign attributeNameFU = attributeName?cap_first>
  <#assign javaType = generator.getJavaType(attributeType)>
  this.${attributeName} = ${generator.getElementProperty(attribute, "entity.default.value")};
</#list>
