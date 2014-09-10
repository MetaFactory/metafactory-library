<#--stop if $currentModelPackage is null-->
<#if !(currentModelPackage)??>  ${generator.error("currentModelPackage not found in context")} </#if>
<#---->
<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>
<#---->
<#assign modelPackage = currentModelPackage>
<#assign modelObjectName = currentModelObject.getAttributeValue("name")>
<#assign modelObjectNameFL = generator.firstLower(modelObjectName)>
<#---->
<#assign className = generator.evaluateExpression("${'$'}{pattern.property.model.implementation.class}", context) >
<#assign isCompositePK = generator.elementContainsProperty(currentModelObject, "database.pk.composite", "true")>
<#---->
if (other == null) return false;
    if (this == other) return true;
    if (!(other instanceof ${className})) return false;

    final ${className} ${modelObjectNameFL} = (${className}) other;
<#---->
<#if isCompositePK >
  <#assign pk = generator.evaluateExpression("${'$'}{pattern.property.pk_composite.name}", context) >
  return equalsByBK(${modelObjectNameFL});
<#else>
  <#assign pk = generator.evaluateExpression("${'$'}{pattern.property.pk}", context) >
    if (this.${pk} != null && ${modelObjectNameFL}.get${pk?cap_first}() != null)
    {
      return equalsByPK(${modelObjectNameFL});
    }
    else
    {
      return equalsByBK(${modelObjectNameFL});
    }
</#if>

