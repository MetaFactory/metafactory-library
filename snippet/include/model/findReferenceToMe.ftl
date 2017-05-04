<#--
  When a object has a reference of type 0..n or 1..n, this snippet is used to find the opposite reference (of type 0..1
  or 1..1).
  The found result is set to these variables:

  referenceToMeName
  referenceToMeNameFU

-->
<#--stop if $modelPackage is null-->
<#if !(modelPackage)??>  ${metafactory.error("modelPackage not found in context")} </#if>

<#--stop if $modelObject is null-->
<#if !(modelObject)??>  <#stop "modelObject not found in context" ></#if>

<#--stop if $modelReference is null-->
<#if !(modelReference)??>  <#stop "modelReference not found in context" ></#if>

<#assign reference = modelReference >
<#assign referenceName = reference.name >
<#assign referenceNameAU = referenceName?upper_case >
<#assign referenceType = reference.type >
<#assign multiplicity = reference.multiplicity >
<#if (multiplicity != "0..n" && multiplicity != "1..n") >
  <#stop "Invalid multiplicity (${multiplicity}) found. Only 0..n and 1..n is supported by addToSet">
</#if>

<#assign modelObjectName = modelObject.name >
<#-- Find the 0..1 or 1..1 reference to me -->
<#assign referenceObjectElement = modelPackage.findObjectByName(referenceType) >

<#--find a reference from this element ($referenceObjectElement) with type modelObjectName -->
<#assign referenceToMeElements = referenceObjectElement.findReferencesByType(modelObjectName) >

<#--remove references with multiplicity other than 0..1 or 1..1 -->
<#list referenceToMeElements as r >
  <#assign multiplicity = r.multiplicity >
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
  <#if (reference.hasMetaData("opposite.reference.tome")) >
    <#assign referenceToMeProperty = reference.getMetaData("opposite.reference.tome") >
    <#assign referenceToMe = referenceObjectElement.findReferenceByName(referenceToMeProperty) >
  <#else>
    <#--
    No property found, so find the object with name referenceType in modelPackage
    Assume the first, but add a property so it's easier to change
    -->
    <#assign referenceToMe = referenceToMeElements.get(0) >
    <#assign name = referenceToMe.name >
    ${reference.addMetaData("opposite.reference.tome", name)}
    ${context.addWarning("ambiguity found: multiple references with type ${modelObjectName} found in object with name ${referenceType}. => Property added to model with assumption of ${name}")}
  </#if>
<#else>
  <#assign referenceToMe = referenceToMeElements.get(0) >
</#if>

<#assign referenceToMeName = referenceToMe.name >
<#assign referenceToMeNameFU = metafactory.firstUpper(referenceToMeName) >
