<#--stop if $currentModelReference is null-->
<#if !(currentModelReference)??>  <#stop "currentModelReference not found in context" ></#if>

<#assign referenceName = currentModelReference.getAttributeValue("name")>
<#assign referenceNameFU = referenceName?cap_first >
<#assign referenceType = currentModelReference.getAttributeValue("type")>
<#assign multiplicity = currentModelReference.getAttributeValue("multiplicity")>
<#assign referenceObjectElement = generator.findChildByAttribute(currentModelPackage, "object" , "name", referenceType)>
<#assign isEnum = generator.getElementProperty(referenceObjectElement, "enum")>
<#assign debugPojo = context.getPatternPropertyValue("debug.pojo","false") >
<#if (debugPojo=="true") >
  LOG.info("set${referenceNameFU}({})", ${referenceName});
</#if>
this.${referenceName} = ${referenceName};