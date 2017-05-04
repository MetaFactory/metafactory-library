<#--stop if $modelPackage is null-->
<#if !(modelPackage)??>  ${metafactory.error("modelPackage not found in context")} </#if>

<#--stop if $modelObject is null-->
<#if !(modelObject)??>   <#stop "modelObject not found in context" ></#if>

<#--stop if $var0 is null-->
<#if !(var0)??>  <#stop "var0 not found in context" ></#if>

<#assign modelObjectName = modelObject.name>
<#assign modelObjectNameFL = modelObjectName?uncap_first>
<#assign modelObjectNamePL = modelObject.getMetaData("name.plural", " ${modelObjectName}s")>
<#assign modelObjectNamePLFL = modelObjectNamePL?uncap_first>

<#--Get all attributes with property "useInConstructor=${var0}" -->
<#assign attributes = modelObject.findAttributesByMetaData("useInConstructor" , var0)>

<#--Get all references with property "useInConstructor=${var0}"-->
<#assign references = modelObject.findReferencesByMetaData("useInConstructor" , var0)>


<#list attributes as attribute>
  <#assign attributeName = attribute.name>
  <#assign attributeType = attribute.type>
  <#assign attributeNameFU = attributeName?cap_first>
  <#assign javaType = metafactory.getJavaType(attributeType)>
  this.${attributeName} = ${attributeName};
</#list>
<#list references as reference>
  <#assign referenceName = reference.name>
  <#assign referenceNameAU = referenceName?upper_case >
  <#assign referenceType = reference.type>
  <#assign multiplicity = reference.multiplicity>
  <#assign referenceObjectElement = modelPackage.findObjectByName(referenceType)>
  <#assign isEnum = referenceObjectElement.getMetaData("enum")>
  this.${referenceName} = ${referenceName};
</#list>












