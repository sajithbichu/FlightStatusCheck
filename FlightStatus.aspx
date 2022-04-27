<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FlightStatus.aspx.cs" Inherits="FlightStatusCheck.FlightStatus" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<link href="Scripts/StyleSheetOne.css" rel="stylesheet" type="text/css" />
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1">
<head runat="server">
    <title></title>

    <script type="text/javascript">  

        $(document).ready(function () {

            LoaderHide();

            var temp = true;
            $("#txtAirportFrom").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: "FlightStatusWS.asmx/GetAirportData",
                        data: "{'airPortName':'" + document.getElementById('txtAirportFrom').value + "'}",
                        dataType: "json",
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        open: function () { $(this).data("ui-autocomplete").menu.bindings = $(); $("#txtAirportTo").autocomplete('close'); },
                        success: function (data) {
                            response(data.d);
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert(textStatus);
                        },
                        select: function (event, ui) {
                            event.preventDefault();
                            $(this).val(ui.item.label).attr('title', ui.item.label);
                            temp = true;
                            return false;
                        }
                    });
                },
                select: function (event, ui) {
                },
                minLength: 0
            }).focus(function () {

                if (temp) {
                    $(this).autocomplete("search");
                    temp = false;
                }

            });

            var temp = true;
            $("#txtAirportTo").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: "FlightStatusWS.asmx/GetAirportData",
                        data: "{'airPortName':'" + document.getElementById('txtAirportTo').value + "'}",
                        dataType: "json",
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        open: function () { $(this).data("ui-autocomplete").menu.bindings = $(); $("#txtAirportTo").autocomplete('close'); },
                        success: function (data) {
                            response(data.d);
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert(textStatus);
                        },
                        select: function (event, ui) {
                            event.preventDefault();
                            $(this).val(ui.item.label).attr('title', ui.item.label);
                            temp = true;
                            return false;
                        }
                    });
                },
                select: function (event, ui) {
                },
                minLength: 0
            }).focus(function () {

                if (temp) {
                    $(this).autocomplete("search");
                    temp = false;
                }

            });

            $("#lnkSwap").click(function (event) {

                var tempFrom = $.trim($("#txtAirportFrom").val());
                var tempTo = $.trim($("#txtAirportTo").val());

                $("#txtAirportFrom").val(tempTo);
                $("#txtAirportTo").val(tempFrom);
            });

            $("#lnkSearch").click(function (event) {

                $("#divError").html("");
                $("#divSearchResultHeader").hide();
                $("#divSearchResultEmpty").hide();
                $("#divSearchResult").hide();
                $("#txtAirportFrom").autocomplete('close');
                $("#txtAirportTo").autocomplete('close');

                if ($.trim($("#txtAirportFrom").val()) == "" && $.trim($("#txtAirportTo").val()) == "") {
                    $("#divError").html("<strong>Errors </br> * Please choose an origin </br> * Please choose a destination</strong>");
                    return false;
                }
                else if ($.trim($("#txtAirportFrom").val()) == "" && $.trim($("#txtAirportTo").val()) != "") {
                    $("#divError").html("<strong>Error </br> * Please choose an origin</strong>");
                    return false;
                }
                else if ($.trim($("#txtAirportFrom").val()) != "" && $.trim($("#txtAirportTo").val()) == "") {
                    $("#divError").html("<strong>Error </br> * Please choose a destination</strong>");
                    return false;
                }
                else if ($.trim($("#txtAirportFrom").val()) == $.trim($("#txtAirportTo").val())) {
                    $("#divError").html("<strong>Error </br> * Origin and destination airport cannot be the same</strong>");
                    return false;
                }
                else {

                    LoaderShow();
                    $("#hFromCode").val($("#txtAirportFrom").val().substring(1, 4));
                    $("#hToCode").val($("#txtAirportTo").val().substring(1, 4));
                    $("#hDate").val($("#ddlDate").val());

                    $.ajax({
                        url: "FlightStatusWS.asmx/GetFlightStatus",
                        data: "{'fromCode':'" + $("#hFromCode").val() + "','toCode':'" + $("#hToCode").val() + "','departureDate':'" + $("#hDate").val() + "'}",
                        dataType: "json",
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        success: function (data) {

                            $("#hSearchResult").val(data.d);

                            if ($("#hSearchResult").val().length > 0) {

                                var searchResultArray = $("#hSearchResult").val().split(',');
                                var flightStatus_HTML = "", flightDetails_HTML = "<table>";

                                for (i = 0; i < searchResultArray.length; i++) {

                                    var flightname, flightno, flightfromCode, flighttoCode, flightfromterminal, flightoterminal, flightstatus, departuretime, arrivaltime;
                                    var tblRowOpen = "<tr>";
                                    var tblRowClose = "</tr>";
                                    var tblCellOpen = "<td>";
                                    var tblCellClose = "</td>";
                                    var departure_time_info = "";
                                    var arrival_time_info = "";

                                    var searchResultArrayDetails = searchResultArray[i].split('|');
                                    flightname = searchResultArrayDetails[0];
                                    flightno = searchResultArrayDetails[1];
                                    flightfromCode = searchResultArrayDetails[2];
                                    flighttoCode = searchResultArrayDetails[3];
                                    flightfromterminal = searchResultArrayDetails[4];
                                    flightoterminal = searchResultArrayDetails[5];
                                    flightstatus = searchResultArrayDetails[6];
                                    departuretime = searchResultArrayDetails[7];
                                    arrivaltime = searchResultArrayDetails[8];

                                    var flightstatus_Color;
                                    var status_icon = "";
                                    if (flightstatus == "ARVD") {
                                        departure_time_info = "Departed: <br/>";
                                        arrival_time_info = "Arrived: <br/>";
                                        flightstatus_Color = "<a class='flightStatusReached'>Flight Arrived</a>";
                                        status_icon = "<img src='Images/flight_landed.png' style='width:30%; height:30%' />";
                                    }
                                    else if (flightstatus == "PDEP") {
                                        departure_time_info = "Scheduled Departure: <br/>";
                                        arrival_time_info = "Estimated Arrival: <br/>";
                                        flightstatus_Color = "<a class='flightStatusNYR'>Not yet departed</a>";
                                        //status_icon = "<img src='Images/flight_not_departed.png' style='width:10%; height:10%' />";
                                    }
                                    else if (flightstatus == "ENRT") {
                                        departure_time_info = "Departed: <br/>";
                                        arrival_time_info = "Estimated Arrival: <br/>";
                                        flightstatus_Color = "<a class='flightStatusNA'>In Flight</a>";
                                        status_icon = "<img src='Images/flight_departed.png' style='width:30%; height:30%' />";
                                    }
                                    else {
                                        departure_time_info = "Scheduled Departure: <br/>";
                                        arrival_time_info = "Estimated Arrival: <br/>";
                                        flightstatus_Color = "<a class='flightStatusNA'>Not yet available</a>";
                                        //status_icon = "<img src='Images/flight_not_departed.png' style='width:10%; height:10%' />";
                                    }

                                    status_icon = "<img src='Images/flight_landed.png' style='width:30%; height:30%' />";
                                    //status_icon = "";

                                    flightDetails_HTML = flightDetails_HTML + tblRowOpen;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + "<strong style='font-size:20px'>" + flightname + " " + flightno + "</strong><br/>" + "Leaving from:<br/><strong style='font-size:20px'>" + "(" + flightfromCode + ") - " + flightfromterminal + "</strong>" + tblCellClose;
                                    //flightDetails_HTML = flightDetails_HTML + tblCellOpen + status_icon + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + "Going to:<br/><strong style='font-size:20px'>" + "(" + flighttoCode + ") - " + flightoterminal + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + "&nbsp;" + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblRowClose;

                                    //flightDetails_HTML = flightDetails_HTML + "<table>";
                                    flightDetails_HTML = flightDetails_HTML + tblRowOpen;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + departure_time_info + "<strong style='font-size:30px'>" + departuretime + "</strong>" + tblCellClose;
                                    //flightDetails_HTML = flightDetails_HTML + tblCellOpen + "" + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + arrival_time_info + "<strong style='font-size:30px'>" + arrivaltime + "</strong>" + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + flightstatus_Color + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblRowClose + "</table>";

                                    flightStatus_HTML = flightStatus_HTML + "<div class='centerResult'>" + flightDetails_HTML + " </div><br />";

                                    flightDetails_HTML = "<table>";

                                }
                                $("#divSearchResult").html(flightStatus_HTML);
                                $("#lblNote").text("Flight status from " + $("#txtAirportFrom").val() + " to " + $("#txtAirportTo").val() + " on " + $("#hDate").val());
                                LoaderHide();
                                $("#divSearchResultEmpty").hide();
                            }
                            else {
                                $("#lblNote").text("No flights available for the selected details.");
                                $("#divLoader").hide();
                                $("#divSearchResultHeader").show();
                                $("#divSearchResult").hide();
                                $("#divSearchResultEmpty").show();
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            LoaderHide();
                            alert(textStatus);
                        }
                    });

                }


            })

        });

        function LoaderHide() {
            $("#divLoader").hide();
            $("#divSearchResultHeader").show();
            $("#divSearchResult").show();
            $("#divSearchResultEmpty").show();
        }
        function LoaderShow() {
            $("#divLoader").show();
            $("#divSearchResultHeader").hide();
            $("#divSearchResult").hide();
            $("#divSearchResultEmpty").hide();
        }


    </script>


</head>
<body>
    <form id="form1" style="" runat="server">
        <img src="Images/EmiratesLogo.png" class="img" alt="logo" />
        <div style="text-align: center; background-color: #686868; color: white; height:70px;">
            <h1>Flight Status Portal</h1>
        </div>
        <br />
        <div class="center">
            <input type="search" class="input input2" value="" id="txtAirportFrom" placeholder="Leaving From" />
            <a href="#" id="lnkSwap">
                <img src="Images/swap.png" style="width: 2%; height: 3%" /></a>
            <input type="search" class="input input2" value="" id="txtAirportTo" placeholder="Going To" />
            <asp:DropDownList ID="ddlDate" class="inputDate input2" runat="server"></asp:DropDownList>
            &nbsp; <a href="#" id="lnkSearch" class="button button2">View Details</a>
        </div>
        <br />
        <div id="divError" style="text-align: left; background-color: pink">
        </div>
        <div class="loader" id="divLoader"></div>
        <div id="divSearchResultHeader" style="text-align: center;">
            <h3>
                <label id="lblNote">Specify the aiports, date and view details.</label>
            </h3>
        </div>
        <br />
        <div id="divSearchResult">
        </div>
        <div id="divSearchResultEmpty"  style="text-align: center;">
           <img src="Images/Emirates-Logo-New.png" style="width: 30%; height: 30%; opacity:0.5"  />
        </div>
        <asp:HiddenField ID="hFromCode" Value="" runat="server" />
        <asp:HiddenField ID="hToCode" Value="" runat="server" />
        <asp:HiddenField ID="hDate" Value="" runat="server" />
        <asp:HiddenField ID="hSearchResult" Value="" runat="server" />
    </form>


</body>


</html>
