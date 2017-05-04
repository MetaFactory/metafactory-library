<#--stop if $modelReference is null-->
<#if !(modelReference)??>  <#stop "modelReference not found in context" ></#if>

<#assign referenceName = modelReference.name>
<#assign referenceNameFU = referenceName?cap_first >
<#assign referenceType = modelReference.type>
<#assign multiplicity = modelReference.multiplicity>
<#assign referenceObjectElement = modelPackage.findObjectByName(referenceType)>
<#assign isEnum = referenceObjectElement.getMetaData("enum")>
<#assign debugPojo = context.getPatternPropertyValue("debug.pojo","false") >
<#if (debugPojo=="true") >
  LOG.info("set${referenceNameFU}({})", ${referenceName});
</#if>
this.${referenceName} = ${referenceName};
