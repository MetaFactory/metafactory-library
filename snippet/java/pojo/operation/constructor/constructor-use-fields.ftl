<#--stop if $currentModelPackage is null-->
<#if !(currentModelPackage)??>  ${generator.error("currentModelPackage not found in context")} </#if>

<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>   <#stop "currentModelObject not found in context" ></#if>

<#--stop if $var0 is null-->
<#if !(var0)??>  <#stop "var0 not found in context" ></#if>

<#assign modelObjectName = currentModelObject.getAttributeValue( "name")>
<#assign modelObjectNameFL = modelObjectName?uncap_first>
<#assign modelObjectNamePL = generator.getElementProperty(currentModelObject, "name.plural", " ${modelObjectName}s")>
<#assign modelObjectNamePLFL = modelObjectNamePL?uncap_first>

<#--Get all attributes with property "useInConstructor=${var0}" -->
<#assign attributes = generator.findChildrenByProperty(currentModelObject, "attribute", "useInConstructor" , var0)>

<#--Get all references with property "useInConstructor=${var0}"-->
<#assign references = generator.findChildrenByProperty(currentModelObject, "reference", "useInConstructor" , var0)>


<#list attributes as attribute>
  <#assign attributeName = attribute.getAttributeValue("name")>
  <#assign attributeType = attribute.getAttributeValue("type")>
  <#assign attributeNameFU = attributeName?cap_first>
  <#assign javaType = generator.getJavaType(attributeType)>
  this.${attributeName} = ${attributeName};
</#list>
<#list references as reference>
  <#assign referenceName = reference.getAttributeValue("name")>
  <#assign referenceNameAU = referenceName?upper_case >
  <#assign referenceType = reference.getAttributeValue("type")>
  <#assign multiplicity = reference.getAttributeValue("multiplicity")>
  <#assign referenceObjectElement = generator.findChildByAttribute(currentModelPackage, "object" , "name" , referenceType)>
  <#assign isEnum = generator.getElementProperty(referenceObjectElement, "enum")>
  this.${referenceName} = ${referenceName};
</#list>












