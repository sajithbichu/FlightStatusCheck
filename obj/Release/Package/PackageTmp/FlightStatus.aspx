<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FlightStatus.aspx.cs" Inherits="FlightStatusCheck.FlightStatus" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<link href="jquery-ui.css" rel="stylesheet" type="text/css" />
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1">
<head runat="server">
    <title></title>

    <script type="text/javascript">  

        $(document).ready(function () {

            LoaderHide();

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
                            return false;
                        }
                    });
                },
                select: function (event, ui) {
                },
                minLength: 0
            }).focus(function () {

                $("#txtAirportTo").autocomplete('close');
                $("#txtAirportTo").blur();
                $(this).data("autocomplete").search($(this).val());

            });

            $("#txtAirportTo").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        url: "FlightStatusWS.asmx/GetAirportData",
                        data: "{'airPortName':'" + document.getElementById('txtAirportTo').value + "'}",
                        dataType: "json",
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        open: function () { $(this).data("ui-autocomplete").menu.bindings = $(); $("#txtAirportFrom").autocomplete('close'); },
                        success: function (data) {
                            response(data.d);
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert(textStatus);
                        },
                        select: function (event, ui) {
                            return false;
                        }
                    });
                },
                minLength: 0
            }).focus(function () {

                $("#txtAirportFrom").autocomplete('close');
                $("#txtAirportFrom").blur();
                $(this).data("autocomplete").search($(this).val());

            });


            $("#lnkSearch").click(function (event) {

                $("#divError").html("");
                $("#divSearchResultHeader").hide();
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
                                    if (flightstatus == "ARVD") {
                                        departure_time_info = "Departed: ";
                                        arrival_time_info = "Arrived: ";
                                        flightstatus_Color = "<a class='flightStatusReached'>Flight Arrived</a>";
                                    }
                                    else if (flightstatus == "PDEP") {
                                        departure_time_info = "Scheduled Departure: ";
                                        arrival_time_info = "Estimated Arrival: ";
                                        flightstatus_Color = "<a class='flightStatusNYR'>Not yet departed</a>";
                                    }
                                    else if (flightstatus == "ENRT") {
                                        departure_time_info = "Departed: ";
                                        arrival_time_info = "Estimated Arrival: ";
                                        flightstatus_Color = "<a class='flightStatusReached'>In Flight</a>";
                                    }
                                    else {
                                        departure_time_info = "Scheduled Departure: ";
                                        arrival_time_info = "Estimated Arrival: ";
                                        flightstatus_Color = "<a class='flightStatusNA'>Not yet available</a>";
                                    }

                                    flightDetails_HTML = flightDetails_HTML + tblRowOpen;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + "<strong style='font-size:20px'>" + flightname + "-" + flightno + "  (" + flightfromCode + ")</strong>" + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + "<strong style='font-size:20px'>" + "(" + flighttoCode + ")</strong > " + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + "" + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblRowClose;

                                    flightDetails_HTML = flightDetails_HTML + tblRowOpen;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + departure_time_info + "<strong style='font-size:35px'>" + departuretime + "</strong>" + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + arrival_time_info + "<strong style='font-size:35px'>" + arrivaltime + "</strong>" + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + flightstatus_Color + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblRowClose;

                                    flightDetails_HTML = flightDetails_HTML + tblRowOpen;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + flightfromterminal + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + flightoterminal + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblCellOpen + "" + tblCellClose;
                                    flightDetails_HTML = flightDetails_HTML + tblRowClose + "</table>";

                                    flightStatus_HTML = flightStatus_HTML + "<div class='centerResult'>" + flightDetails_HTML + " </div><br />";

                                    flightDetails_HTML = "<table>";

                                }
                                $("#divSearchResult").html(flightStatus_HTML);
                                $("#lblNote").text("Flight status from " + $("#txtAirportFrom").val() + " to " + $("#txtAirportTo").val() + " on " + $("#hDate").val());
                                LoaderHide();
                            }
                            else {
                                $("#lblNote").text("No flights available for the selected details.");
                                $("#divLoader").hide();
                                $("#divSearchResultHeader").show();
                                $("#divSearchResult").hide();
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
        }
        function LoaderShow() {
            $("#divLoader").show();
            $("#divSearchResultHeader").hide();
            $("#divSearchResult").hide();
        }


    </script>


</head>
<body>
    <form id="form1" style="" runat="server">
        <img src="Images/EmiratesLogo.png" class="img" alt="logo" />
        <div style="text-align: center;">
            <h1>Flight Status</h1>
        </div>
        <br />
        <div class="center">
            <input type="search" class="input input2" value="" id="txtAirportFrom" placeholder="Leaving From" />
            <input type="search" class="input input2" value="" id="txtAirportTo" placeholder="Going To" />
            <asp:DropDownList ID="ddlDate" class="input input2" runat="server"></asp:DropDownList>
            &nbsp; <a href="#" id="lnkSearch" class="button button2">View Details</a>
        </div>
        <br />
        <div id="divError" style="text-align: left; background-color: pink">
        </div>
        <div class="loader" id="divLoader"></div>
        <div id="divSearchResultHeader" style="text-align: center;">
            <h3>
                <label id="lblNote"></label>
            </h3>
        </div>
        <br />

        <div id="divSearchResult">
        </div>
        <asp:HiddenField ID="hFromCode" Value="" runat="server" />
        <asp:HiddenField ID="hToCode" Value="" runat="server" />
        <asp:HiddenField ID="hDate" Value="" runat="server" />
        <asp:HiddenField ID="hSearchResult" Value="" runat="server" />
    </form>


    <style type="text/css">
        .center {
            padding: 70px 0;
            border: 1px solid gray;
            text-align: center;
            padding: 10px;
            border-radius: 4px;
            box-shadow: 2px 2px 3px 5px lightgray;
        }

        .centerResult {
            padding: 70px 0;
            border: 1px solid gray;
            text-align: center;
            padding: 10px;
            border-radius: 4px;
            box-shadow: 2px 2px 3px 5px lightgray;
            width: 80%;
            position: relative;
            right: -10%;
        }

        .button {
            background-color: red;
            border: none;
            color: white;
            padding: 10px 25px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 4px 2px;
            cursor: pointer;
            -webkit-transition-duration: 0.4s;
            transition-duration: 0.4s;
            border-radius: 8px;
        }


        .flightStatusReached {
            background-color: green;
            border: none;
            color: white;
            padding: 10px 25px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 4px 2px;
            cursor: none;
            -webkit-transition-duration: 0.4s;
            transition-duration: 0.4s;
            position: absolute;
            right: -5%;
            width: 160px;
            top: 7%;
        }

        .flightStatusNYR {
            background-color: blue;
            border: none;
            color: white;
            padding: 10px 25px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 4px 2px;
            cursor: none;
            -webkit-transition-duration: 0.4s;
            transition-duration: 0.4s;
            position: absolute;
            right: -5%;
            width: 160px;
            top: 7%;
        }

        .flightStatusNA {
            background-color: #FFBF00;
            border: none;
            color: white;
            padding: 10px 25px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 4px 2px;
            cursor: none;
            -webkit-transition-duration: 0.4s;
            transition-duration: 0.4s;
            position: absolute;
            right: -5%;
            width: 160px;
            top: 7%;
        }

        .button2:hover {
            box-shadow: 0 12px 16px 0 rgba(0,0,0,0.24),0 17px 50px 0 rgba(0,0,0,0.19);
        }

        .input {
            border: 1px solid gray;
            border-radius: 3px;
            padding: 0px 5px;
            height: 50px;
            width: 300px;
            position: relative;
        }

        .input2:hover {
            box-shadow: 0 6px 10px 0 rgba(0,0,0,0.24),0 17px 50px 0 rgba(0,0,0,0.19);
        }

        .ui-menu {
            position: relative;
            list-style: none;
            background-color: white;
            border-radius: 10px;
            /*            z-index:30 !important;*/
            width: 400px;
            line-height: 250%;
            font-size: 12px;
            padding: 15px 0;
            border: solid 1px grey;
            box-shadow: 0 6px 10px 0 rgba(0,0,0,0.24),0 17px 50px 0 rgba(0,0,0,0.19);
            cursor: pointer;
        }

            .ui-menu .ui-menu-item {
                margin: none;
                padding-left: 15px;
                padding-right: 10px;
            }

                .ui-menu .ui-menu-item:hover {
                    background-color: silver;
                    font-size: 14px;
                    font-weight: bold;
                }

        #ui-id-1 {
            display: block !important;
        }



        * {
            box-sizing: border-box;
        }

        .row {
            margin-left: -5px;
            margin-right: -5px;
        }

        .column {
            float: left;
            width: 50%;
            padding: 5px;
        }

        /* Clearfix (clear floats) */
        .row::after {
            content: "";
            clear: both;
            display: table;
        }

        table {
            border-collapse: collapse;
            border-spacing: 0;
            width: 100%;
            border: 1px solid #ddd;
        }

        th, td {
            text-align: left;
            padding: 16px;
        }

        tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        .loader {
            position: absolute;
            left: 45%;
            top: 50%;
            border: 16px solid red;
            border-radius: 50%;
            border-top: 16px solid silver;
            width: 120px;
            height: 120px;
            -webkit-animation: spin 2s linear infinite; /* Safari */
            animation: spin 2s linear infinite;
        }

        /* Safari */
        @-webkit-keyframes spin {
            0% {
                -webkit-transform: rotate(0deg);
            }

            100% {
                -webkit-transform: rotate(360deg);
            }
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }

        .img {
            float: left;
            width: 100px;
            height: 100px;
            background: #555;
            position: relative;
            top: 3px;
            right: -20px;
        }
    </style>

</body>


</html>
