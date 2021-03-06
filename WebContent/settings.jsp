<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="edu.stanford.muse.webapp.ModeConfig"%>
<%@page import="edu.stanford.muse.index.ArchiveReaderWriter"%>
<%@include file="getArchive.jspf" %>

<!DOCTYPE HTML>
<html lang="en">
<head>
    <title>ePADD Settings</title>
    <link rel="icon" type="image/png" href="images/epadd-favicon.png">

    <link rel="stylesheet" href="bootstrap/dist/css/bootstrap.min.css">

	<jsp:include page="css/css.jsp"/>
	<link rel="stylesheet" href="css/sidebar.css">

	<script src="js/jquery.js"></script>

	<script type="text/javascript" src="bootstrap/dist/js/bootstrap.min.js"></script>
	<script src="js/modernizr.min.js"></script>
	<script src="js/sidebar.js"></script>

	<script src="js/epadd.js"></script>
	<script src="js/stacktrace.js"></script>
	<style>
		#advanced_options button {width:250px;}
        #advanced_options input {width:250px;}
	</style>
</head>
<body style="color:gray;">
<%@include file="header.jspf"%>
<%writeProfileBlock(out, archive, "Settings");%>

<jsp:include page="alert.jspf"/>

<p>

    <div style="width:1100px; margin:auto">
	<%
        if (archive != null) { %>
            <div id="advanced_options">

            <% if (!ModeConfig.isDiscoveryMode()) { %>
<p><button onclick="window.location='verify-bag?archiveID=<%=archiveID%>'" class="btn-default" style="cursor:pointer">Verify bag checksum</button></p>
<p>    <button id="debugaddressbook" onclick="window.location='debugAddressBook?archiveID=<%=archiveID%>'"  class="btn-default" style="cursor:pointer">Debug address book</button></p>

<section>
    <div class="panel" id="export-headers">
        <div class="panel-heading">Trusted Address Computation</div>

        <div class="one-line">
            <div class="form-group col-sm-4">
                <%--<label for="trustedaddrsForComputation">Trusted emails addresses</label>--%>
                <input type="text" placeholder="';' separated trusted email addresses" id="trustedaddrsForComputation"></input>
            </div>
            <div class="form-group col-sm-5">
                <%--<label for="outgoingthreshold">Outgoing messages threshold</label>--%>
                <input type="text" placeholder="Min. outgoing messages (e.g. 10)" id="outgoingthreshold"></input>
            </div>
            <div class="form-group col-sm-2 picker-buttons">
                <button id="moreComputation" onclick="computeMoreTrustedAddressHandler();return false;" class="btn-default" style="cursor:pointer">Get Trusted Addresses</button>
            </div>
        </div>
        <br/>
        <br/>
            <div class="form-group col-sm-4">
                <input type="text" id="result-more-trusted" placeholder="RESULT" readonly></input>
            </div>
        <br/>
        <br/>
    </div>
</section>

<section>
    <div class="panel" id="recomputation">
        <div class="panel-heading">Addrssbook recomputation</div>

<div class="one-line" >
    <input type="text" placeholder="';' separated trusted email addresses" id="trustedaddrs"></input>
<button id="recomputebutton" onclick="recomputeAddressBookHandler();return false;" class="btn-default" style="cursor:pointer">Recompute Address Book</button>
</div>
    </div>
</section>

<section>
    <div class="panel" id="ownersetting">
        <div class="panel-heading">Set Owner's Contact</div>

<div class="one-line" >
    <input type="text" placeholder="owner's email id (Separated by ';' if multiple)" id="ownermailid"></input>
    <button id="owenersetting" onclick="setOwnerMailHandler();return false;" class="btn-default" style="cursor:pointer">Set as Owner</button>
</div>
    </div>
</section>
        <script>
            var setOwnerMailHandler = function(){
                var archiveID='<%=archiveID%>';
                //get owners address. In case of more than one separate by ;.
                // If empty then prompt user to provide at least one  address.
                var ownersaddress = $('#ownermailid').val();
                ownersaddress = ownersaddress.trim();
                if (!ownersaddress) {
                    epadd.error("Please provide at least one owner's email address!");
                    return;
                }
                //else perform an ajax call.
                //on succesful execution of the call redirect to browse-top page.
                // var $spinner = $('#spinner-div');
                // $spinner.show();
                // $spinner.addClass('fa-spin');
                // $('#spinner-div').fadeIn();
                // $('#recomputebutton').fadeOut();
                var data = {'archiveID': archiveID,'ownersaddress':ownersaddress};
                var params = epadd.convertParamsToAmpersandSep(data)
                var promptmethod = function(j){
                    epadd.info("Successfully set the owner's addresses",function(){
                        window.location = './browse-top?archiveID=' +archiveID;
                    })                }
                fetch_page_with_progress("ajax/async/setOwnersAddress.jsp", "status", document.getElementById('status'), document.getElementById('status_text'), params,promptmethod);

               /* $.ajax({type: 'POST',
                    dataType: 'json',
                    url: 'ajax/setOwnersAddress.jsp',
                    data: data,
                    success: function (response) {
                        $spinner.removeClass('fa-spin');
                        // $('#spinner-div').fadeOut();
                        // $('#recomputebutton').fadeIn();

                        if (response) {
                            if (response.status === 0) {
                                epadd.info("Successfully set the owner's addresses",function(){
                                    window.location = './browse-top?archiveID=' +archiveID;
                                })
                            } else{

                                epadd.error('Error setting the owner\'s addresses ' + response.status + ', Message: ' + response.error, function(){
                                    //window.location = './browse-top?archiveID=' +archiveID;
                                });
                            }
                        }
                        else{
                            epadd.error('Error setting the owner\'s addresses. Improper response received!', function(){
                                //window.location = './browse-top?archiveID=' +archiveID;
                            });
                        }
                    },
                    error: function(jq, textStatus, errorThrown) {
                        // $('#spinner-div').fadeOut();
                        // $('#recomputebutton').fadeIn();
                        epadd.error('Sorry, there was an error while setting the owner\'s address. The ePADD program has either quit, or there was an internal error. Please retry and if the error persists, report it to epadd_project@stanford.edu.', function(){
                            window.location = './browse-top?archiveID=' +archiveID;
                        });
                    }
                });*/
            };

    var computeMoreTrustedAddressHandler = function(){
        var archiveID='<%=archiveID%>';
        //get list of trusted addresses. If empty then prompt user to provide at least one trusted address.
        var trustedaddrs = $('#trustedaddrsForComputation').val();
        trustedaddrs = trustedaddrs.trim();
        if (!trustedaddrs) {
            epadd.error("Please provide at least one trusted email address for Addressbook construction!");
            return;
        }
        //get offset count, if nothing provided pass -1. On the server side it will assume infinity (or a very large value)
        var outcountoffset = $('#outgoingthreshold').val();
        if(isNaN(parseInt(outcountoffset)))
            outcountoffset=-1;
        else
            outcountoffset=parseInt(outcountoffset);

        //after ajax call returns set the result in the text box $('#result-more-trusted').val(RESULT)
//else perform an ajax call.
        //on succesful execution of the call redirect to browse-top page.
        var $spinner = $('#spinner-div');
        $spinner.show();
        $spinner.addClass('fa-spin');
        $('#spinner-div').fadeIn();
        $('#recomputebutton').fadeOut();
        var data = {'archiveID': archiveID,'trustedaddrs':trustedaddrs,'outoffset':outcountoffset};


        $.ajax({type: 'POST',
            dataType: 'json',
            url: 'ajax/computeTrustedAddresses.jsp',
            data: data,
            success: function (response) {
                $spinner.removeClass('fa-spin');
                $('#spinner-div').fadeOut();
                $('#recomputebutton').fadeIn();

                if (response) {
                    if (response.status === 0) {
                        epadd.info("Successfully computed the trusted addresses",function(){
                            $('#result-more-trusted').val(response.result)
                        })
                    } else{

                        epadd.error('Error recomputing the trusted addresses ' + response.status + ', Message: ' + response.error);
                    }
                }
                else{
                    epadd.error('Error recomputing the trusted addresses. Improper response received!');
                }
            },
            error: function(jq, textStatus, errorThrown) {
                $('#spinner-div').fadeOut();
                $('#recomputebutton').fadeIn();
                epadd.error('Sorry, there was an error while computing the trusted addresses. The ePADD program has either quit, or there was an internal error. Please retry and if the error persists, report it to epadd_project@stanford.edu.');
            }
        });
    };
    var recomputeAddressBookHandler = function(){
        var archiveID='<%=archiveID%>';
        //get list of trusted addresses. If empty then prompt user to provide at least one trusted address.
        var trustedaddrs = $('#trustedaddrs').val();
        trustedaddrs = trustedaddrs.trim();
        if (!trustedaddrs) {
            epadd.error("Please provide at least one trusted email address for Addressbook construction!");
            return;
        }
        //else perform an ajax call.
        //on succesful execution of the call redirect to browse-top page.
        var $spinner = $('#spinner-div');
        $spinner.show();
        $spinner.addClass('fa-spin');
        $('#spinner-div').fadeIn();
        $('#recomputebutton').fadeOut();
        var data = {'archiveID': archiveID,'trustedaddrs':trustedaddrs};
        var params = epadd.convertParamsToAmpersandSep(data)
        var promptmethod = function(j){
            epadd.info("Successfully recomputed the address book.",function(){
                window.location = './browse-top?archiveID=' +archiveID;
            })                }
        fetch_page_with_progress("ajax/async/recomputeAddressbook.jsp", "status", document.getElementById('status'), document.getElementById('status_text'), params,promptmethod);


        /*$.ajax({type: 'POST',
            dataType: 'json',
            url: 'ajax/recomputeAddressbook.jsp',
            data: data,
            success: function (response) {
                $spinner.removeClass('fa-spin');
                $('#spinner-div').fadeOut();
                $('#recomputebutton').fadeIn();

                if (response) {
                    if (response.status === 0) {
                        epadd.info("Successfully recomputed the addressbook",function(){
                          window.location = './browse-top?archiveID=' +archiveID;
                        })
                    } else{

                        epadd.error('Error recomputing the addressbook ' + response.status + ', Message: ' + response.error, function(){
                            window.location = './browse-top?archiveID=' +archiveID;
                        });
                    }
                }
                else{
                    epadd.error('Error recomputing the addressbook. Improper response received!', function(){
                        window.location = './browse-top?archiveID=' +archiveID;
                    });
                }
            },
            error: function(jq, textStatus, errorThrown) {
                $('#spinner-div').fadeOut();
                $('#recomputebutton').fadeIn();
                epadd.error('Sorry, there was an error while recomputing the addressbook. The ePADD program has either quit, or there was an internal error. Please retry and if the error persists, report it to epadd_project@stanford.edu.', function(){
                    window.location = './browse-top?archiveID=' +archiveID;
                });
            }
        });*/


    };
</script>
                <% if (ModeConfig.isAppraisalMode() || ModeConfig.isProcessingMode()) { %>
                    <%--NO LONGER NEEDED THIS FUNCTIONALITY HERE<p><button onclick="window.location='set-images?archiveID=<%=archiveID%>';" class="btn-default" style='cursor:pointer' ><i class="fa fa-picture-o"></i> Set Images</button></p>--%>
                <% }
            } /* archive != null */
        }
    %>

    </div>

</body>
</html>
