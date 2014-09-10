<#--
  When a object has a reference of type 0..n or 1..n, this snippet is used to find the opposite reference (of type 0..1
  or 1..1).
  The found result is set to these variables:

  referenceToMeName
  referenceToMeNameFU

-->
<#--stop if $currentModelPackage is null-->
<#if !(currentModelPackage)??>  ${generator.error("currentModelPackage not found in context")} </#if>

<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??>  <#stop "currentModelObject not found in context" ></#if>

<#--stop if $currentModelReference is null-->
<#if !(currentModelReference)??>  <#stop "currentModelReference not found in context" ></#if>

<#assign reference = currentModelReference >
<#assign referenceName = reference.getAttributeValue("name") >
<#assign referenceNameAU = referenceName?upper_case >
<#assign referenceType = reference.getAttributeValue("type") >
<#assign multiplicity = reference.getAttributeValue("multiplicity") >
<#if (multiplicity != "0..n" && multiplicity != "1..n") >
  <#stop "Invalid multiplicity (${multiplicity}) found. Only 0..n and 1..n is supported by addToSet">
</#if>

<#assign modelObjectName = currentModelObject.getAttributeValue('name') >
<#-- Find the 0..1 or 1..1 reference to me -->
<#assign referenceObjectElement = generator.findChildByAttribute(currentModelPackage,"object","name",referenceType) >

<#--find a reference from this element ($referenceObjectElement) with type modelObjectName -->
<#assign referenceToMeElements = generator.findChildrenByAttribute(referenceObjectElement,"reference","type",modelObjectName) >

<#--remove references with multiplicity other than 0..1 or 1..1 -->
<#list referenceToMeElements as r >
  <#assign multiplicity = r.getAttributeValue('multiplicity') >
  <#if (multiplicity != "0..1" && multiplicity != "1..1") >
    ${referenceToMeElements.remove(r)}
  </#if>
</#list>

<#--
when multiple references found, generate a error with instruction how to add a property to distinguish these references
when no references found genereate a error
when only 1 reference found, create the value of the mappedBy attribute and insert the OneToMany annotation
-->
<#if (referenceToMeElements.size()==0) >
  <#stop "Invalid model: No reference 0..1 or 1..1 of type ${modelObjectName} found in object with name ${referenceType}." >
<#elseif (referenceToMeElements.size()>1) >
  <#--The reference to me can be explicitly set in a property (to remove a ambiguity), so first check if there's a property set -->
  <#if (generator.elementContainsProperty(reference,"opposite.reference.tome")) >
    <#assign referenceToMeProperty = generator.getElementProperty(reference,"opposite.reference.tome") >
    <#assign referenceToMe = generator.findChildByAttribute(referenceObjectElement,"reference","name",referenceToMeProperty) >
  <#else>
    <#--
    No property found, so find the object with name referenceType in currentModelPackage
    Assume the first, but add a property so it's easier to change
    -->
    <#assign referenceToMe = referenceToMeElements.get(0) >
    <#assign name = referenceToMe.getAttributeValue("name") >
    ${generator.addProperty(reference,"opposite.reference.tome",name)}
    ${context.addWarning("ambiguity found: multiple references with type ${modelObjectName} found in object with name ${referenceType}. => Property added to model with assumption of ${name}")}
  </#if>
<#else>
  <#assign referenceToMe = referenceToMeElements.get(0) >
</#if>

<#assign referenceToMeName = referenceToMe.getAttributeValue('name') >
<#assign referenceToMeNameFU = generator.firstUpper(referenceToMeName) >
