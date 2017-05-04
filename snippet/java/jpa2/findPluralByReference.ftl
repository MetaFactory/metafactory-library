<#--stop if $modelPackage is null-->
<#if !(modelPackage)??>  ${metafactory.error("modelPackage not found in context")} </#if>
<#---->
<#--stop if $modelObject is null-->
<#if !(modelObject)??> <#stop "modelObject not found in context" > </#if>
<#---->
<#--stop if $modelReference is null-->
<#if !(modelReference)??>  <#stop "modelReference not found in context" ></#if>
<#---->
<#assign referenceName = modelReference.name>
<#assign referenceNameAU = referenceName?upper_case >
<#assign referenceNameFU = referenceName?cap_first >
<#assign referenceType = modelReference.type>
<#assign multiplicity = modelReference.multiplicity>
<#assign referenceObjectElement = modelPackage.findObjectByName(referenceType)>
<#assign isEnum = referenceObjectElement.getMetaData("enum")>
<#global getEm = context.getPatternPropertyValue("dao.getEntityManager") >

<#-- packageName contains the name of the package of the pojo's -->
<#assign packageName = metafactory.evaluateExpression("${'$'}{pattern.property.model.implementation.package}", context) >

<#-- className contains the name of the class of a pojo which is created foreach model object -->
<#assign className = metafactory.evaluateExpression("${'$'}{pattern.property.model.implementation.class}", context) >
<#assign reference = metafactory.evaluateExpression("${'$'}{pattern.property.model.implementation.reference}", context) >
${metafactory.addLibraryToClass("javax.persistence.criteria.CriteriaBuilder")}
${metafactory.addLibraryToClass("javax.persistence.criteria.CriteriaQuery")}
${metafactory.addLibraryToClass("javax.persistence.criteria.Root")}
${metafactory.addLibraryToClass("javax.persistence.TypedQuery")}
${metafactory.addLibraryToClass("javax.persistence.criteria.Expression")}

CriteriaBuilder cb = ${getEm}.getCriteriaBuilder();
CriteriaQuery<${className}> cq = cb.createQuery(${className}.class);

Root<${className}> from${className} = cq.from(${className}.class);

<#if isEnum=="true">
  Expression<Boolean> equal${referenceNameFU} = cb.equal(from${className}.get(${className}_.${referenceName}), ${referenceName});
<#else>
  // join on ${referenceType}
  ${metafactory.addLibraryToClass("${packageName}.${className}_")}
  ${metafactory.addLibraryToClass("javax.persistence.criteria.Join")}
  Join<${className}, ${reference}> ${referenceName}Join = from${className}.join(${className}_.${referenceName});
  Expression<Boolean> equal${referenceNameFU} = cb.equal(${referenceName}Join, ${referenceName});
</#if>

<#--
  This method is used to create the finder method to find a list of objects by using some reference. Creation of this method
  is triggered by the property dao.finder.list=true on some reference of current model object.
  It must be possible to sort this list by some other attribute or reference of this object. To know which attributes and
  references must be used for sorting we are looking for the attributes and references with the property
  dao.finder.list.sort=<referenceName>
  Get all the attributes and references of current model object which must be used for sorting in this finder method => which has property dao.finder.list.sort=${referenceName}
-->
<#assign sortAttributes = modelObject.findAttributesByMetaData("dao.finder.list.sort", "${referenceName}" )>
<#assign sortReferences = modelObject.findReferencesByMetaData("dao.finder.list.sort", "${referenceName}" )>
<#assign all = sortAttributes + sortReferences>

<#if all?size &gt; 0 >
  ${metafactory.addLibraryToClass("javax.persistence.criteria.Path")}
  <#list all as item>
    <#assign itemName = item.name>
    <#assign sortAscending = item.getMetaData("dao.finder.list.sort.${referenceName}", "true")>
    // sort by ${className}.${itemName}
    <#if sortAscending == "true" >
      cq.orderBy(cb.asc(from${className}.get(${className}_.${itemName})));
    <#else>
      cq.orderBy(cb.desc(from${className}.get(${className}_.${itemName})));
    </#if>
  </#list>

</#if>
cq.select(from${className}).where(equal${referenceNameFU});

TypedQuery<${className}> q = ${getEm}.createQuery(cq);
List<${className}> result = q.getResultList();

return result;

