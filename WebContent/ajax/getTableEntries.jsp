<%@page language="java" import="edu.stanford.muse.ie.InternalAuthorityAssigner"%>
<%@page language="java" import="edu.stanford.muse.ie.Entities"%>
<%@page language="java" import="edu.stanford.muse.ie.EntityFeature"%>
<%@page language="java" import="edu.stanford.muse.index.Archive"%>
<%@page language="java" import="edu.stanford.muse.util.Pair"%>
<%@page language="java" import="edu.stanford.muse.util.Util"%>
<%@page language="java" import="edu.stanford.muse.webapp.JSPHelper"%>
<%@page language="java" import="java.util.ArrayList"%>
<%@page language="java" import="java.util.List"%>
<%@ page import="org.json.JSONObject" %>
<%
	Archive archive = JSPHelper.getArchive(session);

	InternalAuthorityAssigner assignauthorities = (InternalAuthorityAssigner) session.getAttribute("authorities");
	if (assignauthorities == null) {
        assignauthorities = InternalAuthorityAssigner.load(archive); // read from .ser file
		if (assignauthorities == null) {
			assignauthorities = new InternalAuthorityAssigner();
			session.setAttribute("statusProvider", assignauthorities);
			assignauthorities.initialize(archive);
			session.removeAttribute("statusProvider");
		}
        session.setAttribute("authorities", assignauthorities);
    }

	String type = request.getParameter("type");
	String db = request.getParameter("db");
	String bi = request.getParameter("bi");
	String ei = request.getParameter("ei");
	int beginIdx = Integer.parseInt(bi);
	int endIdx = Integer.parseInt(ei);	
	JSPHelper.log.info("beginIdx: " + beginIdx + ", endIdx: " + endIdx);
	
	JSPHelper.log.info("Received type: "+type+" authorities is "+(assignauthorities));
	//type = "person";
	Entities entitiesData = null;	
	if (assignauthorities != null && type != null){
		if(type.equals("correspondent")){
			entitiesData = assignauthorities.entitiesData.get(EntityFeature.CORRESPONDENT);
			JSPHelper.log.info("Number of correspondents: " + entitiesData.size());
		}	
		else if(type.equals("person")){
			// now, lookup every entity, printing those that are either already confirmed, or have hits in the FAST db
			entitiesData = assignauthorities.entitiesData.get(EntityFeature.PERSON);
			JSPHelper.log.info("Number of persons entities: " + entitiesData.size());
		}
		else if(type.equals("org")){
			entitiesData = assignauthorities.entitiesData.get(EntityFeature.ORG);
			JSPHelper.log.info("Number of org entities: " + entitiesData.size());
		}
		else if(type.equals("places")){
			entitiesData = assignauthorities.entitiesData.get(EntityFeature.PLACE);
			JSPHelper.log.info("Number of places entities: " + entitiesData.size());
		}
	}
	session.setAttribute("statusProvider", entitiesData);

	long startMillis = System.currentTimeMillis();
	//this is table data in the form of Array of JSON objects and each JSON object in turn contains
	//values, contexts and classes for each row
	JSONObject tabledata = null;
	try {
		Entities.Info info = new Entities.Info(type,db,false);
		tabledata = entitiesData.getJSONObjectFor(beginIdx, endIdx, info, archive);
	} catch(Exception e){
		Util.print_exception("Error getting entities info: ", e, JSPHelper.log);
	}

	if (tabledata != null)
		response.getWriter().write(tabledata.toString());
	session.removeAttribute("statusProvider");
	JSPHelper.log.info("Assign authorities lookup took " + (Util.commatize(System.currentTimeMillis() - startMillis)) + " ms");
	return;
%>