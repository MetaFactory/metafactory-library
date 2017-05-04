<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>

<#assign modelObjectName = modelObject.name>
<#assign modelObjectNameFL = modelObjectName?uncap_first>

  StringBuilder result = new StringBuilder("${modelObjectName}: ");

<#assign attributes = modelObject.getAttributes()>
<#list attributes as attribute>
  <#assign attributeName = attribute.name>
  <#assign attributeType = attribute.type>
  <#assign javaType = metafactory.getJavaType(attributeType)>
  <#-- Add a , after first iteration of this loop using index variable created by freemarker -->
  <#if (attribute_index > 0) >
    result.append(", ");
  </#if>

  <#if (metafactory.isPrimitiveJavaType(attributeType)) >
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
