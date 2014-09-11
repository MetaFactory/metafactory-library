<#--stop if $currentModelPackage is null-->
<#if !(currentModelPackage)??>  ${generator.error("currentModelPackage not found in context")} </#if>
<#---->
<#--stop if $currentModelObject is null-->
<#if !(currentModelObject)??> <#stop "currentModelObject not found in context" > </#if>
<#---->
<#--stop if $currentModelReference is null-->
<#if !(currentModelReference)??>  <#stop "currentModelReference not found in context" ></#if>
<#---->
<#assign referenceName = currentModelReference.getAttributeValue("name")>
<#assign referenceNameAU = referenceName?upper_case >
<#assign referenceNameFU = referenceName?cap_first >
<#assign referenceType = currentModelReference.getAttributeValue("type")>
<#assign multiplicity = currentModelReference.getAttributeValue("multiplicity")>
<#assign referenceObjectElement = generator.findChildByAttribute(currentModelPackage, "object" , "name", referenceType)>
<#assign isEnum = generator.getElementProperty(referenceObjectElement, "enum")>
<#global getEm = context.getPatternPropertyValue("dao.getEntityManager") >

<#-- packageName contains the name of the package of the pojo's -->
<#assign packageName = generator.evaluateExpression("${'$'}{pattern.property.model.implementation.package}", context) >

<#-- className contains the name of the class of a pojo which is created foreach model object -->
<#assign className = generator.evaluateExpression("${'$'}{pattern.property.model.implementation.class}", context) >
<#assign reference = generator.evaluateExpression("${'$'}{pattern.property.model.implementation.reference}", context) >
${generator.addLibraryToClass("javax.persistence.criteria.CriteriaBuilder")}
${generator.addLibraryToClass("javax.persistence.criteria.CriteriaQuery")}
${generator.addLibraryToClass("javax.persistence.criteria.Root")}
${generator.addLibraryToClass("javax.persistence.TypedQuery")}
${generator.addLibraryToClass("javax.persistence.criteria.Expression")}

CriteriaBuilder cb = ${getEm}.getCriteriaBuilder();
CriteriaQuery<${className}> cq = cb.createQuery(${className}.class);

Root<${className}> from${className} = cq.from(${className}.class);

<#if isEnum=="true">
  Expression<Boolean> equal${referenceNameFU} = cb.equal(from${className}.get(${className}_.${referenceName}), ${referenceName});
<#else>
  // join on ${referenceType}
  ${generator.addLibraryToClass("${packageName}.${className}_")}
  ${generator.addLibraryToClass("javax.persistence.criteria.Join")}
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
<#assign sortAttributes = generator.findChildrenByProperty(currentModelObject, "attribute" , "dao.finder.list.sort", "${referenceName}" )>
<#assign sortReferences = generator.findChildrenByProperty(currentModelObject, "reference" , "dao.finder.list.sort", "${referenceName}" )>
<#assign all = sortAttributes + sortReferences>

<#if all?size &gt; 0 >
  ${generator.addLibraryToClass("javax.persistence.criteria.Path")}
  <#list all as item>
    <#assign itemName = item.getAttributeValue("name")>
    <#assign sortAscending = generator.getElementProperty(item,"dao.finder.list.sort.${referenceName}","true")>
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

