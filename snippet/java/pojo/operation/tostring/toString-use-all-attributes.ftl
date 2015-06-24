<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>

<#assign modelObjectName = currentModelObject.getAttributeValue("name")>
<#assign modelObjectNameFL = modelObjectName?uncap_first>

  StringBuilder result = new StringBuilder("${modelObjectName}: ");

<#assign attributes = currentModelObject.getChildren("attribute", nsModel)>
<#list attributes as attribute>
  <#assign attributeName = attribute.getAttributeValue( "name")>
  <#assign attributeType = attribute.getAttributeValue( "type")>
  <#assign javaType = generator.getJavaType(attributeType)>
  <#-- Add a , after first iteration of this loop using index variable created by freemarker -->
  <#if (attribute_index > 0) >
    result.append(", ");
  </#if>

  <#if (generator.isPrimitiveJavaType(attributeType)) >
    result.append("${attributeName}=" + ${attributeName}); // I am primitive
  <#else>
  <#-- handle primitive types other than objects -->
    <#if (javaType == "String") >
      result.append("${attributeName}=" + ${attributeName});
    <#else>
      result.append("${attributeName}=" + ${attributeName}.toString());
    </#if>
  </#if>
</#list>

return result.toString();