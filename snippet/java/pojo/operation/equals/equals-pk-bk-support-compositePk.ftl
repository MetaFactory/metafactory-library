<#--stop if $modelPackage is null-->
<#if !(modelPackage)??>  ${metafactory.error("modelPackage not found in context")} </#if>
<#---->
<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>
<#---->

<#assign modelObjectName = modelObject.name>
<#assign modelObjectNameFL = metafactory.firstLower(modelObjectName)>
<#---->
<#assign className = metafactory.evaluateExpression("${'$'}{pattern.property.model.implementation.class}", context) >
<#assign isCompositePK = modelObject.hasMetaData("database.pk.composite", "true")>
<#---->
if (other == null) return false;
    if (this == other) return true;
    if (!(other instanceof ${className})) return false;

    final ${className} ${modelObjectNameFL} = (${className}) other;
<#---->
<#if isCompositePK >
  <#assign pk = metafactory.evaluateExpression("${'$'}{pattern.property.pk_composite.name}", context) >
  return equalsByBK(${modelObjectNameFL});
<#else>
  <#assign pk = metafactory.evaluateExpression("${'$'}{pattern.property.pk}", context) >
    if (this.${pk} != null && ${modelObjectNameFL}.get${pk?cap_first}() != null)
    {
      return equalsByPK(${modelObjectNameFL});
    }
    else
    {
      return equalsByBK(${modelObjectNameFL});
    }
</#if>

