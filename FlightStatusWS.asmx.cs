using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.IO;
using System.Data;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


namespace FlightStatusCheck
{
    /// <summary>
    /// Summary description for FlightStatusWS
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    [System.Web.Script.Services.ScriptService]
    public class FlightStatusWS : System.Web.Services.WebService
    {

        [WebMethod]
        public List<string> GetAirportData(string airPortName)
        {
            List<string> lstOfAirPorts = new List<string>();
            var webclient = new WebClient();
            var json = webclient.DownloadString(@"" + System.Configuration.ConfigurationManager.AppSettings["AirportListJsonPath"]);

            JObject jObj = (JObject)JsonConvert.DeserializeObject(json);
            foreach (var level1 in jObj)
            {
                var jObjKey = level1.Key;
                JObject finalLoop = (JObject)JsonConvert.DeserializeObject(level1.Value.ToString());

                foreach (var level2 in finalLoop)
                {
                    if (level2.Value.Count() > 1)
                    {
                        Dictionary<string, object> dictObj = JsonConvert.DeserializeObject<Dictionary<string, object>>(level2.Value.ToString());
                        Dictionary<string, object> dictObj_country = JsonConvert.DeserializeObject<Dictionary<string, object>>(dictObj["country"].ToString());
                        lstOfAirPorts.Add("(" + dictObj["iataCode"].ToString() + ") " + dictObj["longName"].ToString() + ", " + dictObj_country["longName"].ToString());
                    }
                }
            }
            if (airPortName.Trim().Length > 0)
                lstOfAirPorts = lstOfAirPorts.Where(x => x.ToUpper().Contains(airPortName.ToUpper())).Take(10).ToList();
            else
                lstOfAirPorts = lstOfAirPorts.Take(10).ToList();
            return lstOfAirPorts;
        }

        [WebMethod]
        public List<string> GetFlightStatus(string fromCode, string toCode, string departureDate)
        {
            try
            {
                List<string> lstSearchResult = new List<string>();
                var url = System.Configuration.ConfigurationManager.AppSettings["FlightDetailsWebLink"] + departureDate + "&origin=" + fromCode + "&destination=" + toCode;

                WebRequest request = HttpWebRequest.Create(url);
                WebResponse response = request.GetResponse();
                StreamReader reader = new StreamReader(response.GetResponseStream());
                string responseText = reader.ReadToEnd();
                JObject jObj = (JObject)JsonConvert.DeserializeObject(responseText);

                if (responseText.ToString().IndexOf(":null") != 10)
                {
                    foreach (var level1 in jObj)
                    {
                        var jObjKey = level1.Key;

                        if (level1.Value.ToString().IndexOf("href") == -1)
                        {
                            JArray jArray = JArray.Parse(level1.Value.ToString());
                            string item_val, item_val2 = "", item_val3 = "", item_val4 = "";

                            foreach (JObject item in jArray)
                            {
                                item_val = item.GetValue("airlineDesignator").ToString() + "|"
                                     + item.GetValue("flightNumber").ToString() + "|";

                                JArray jArray2 = JArray.Parse(item.GetValue("flightRoute").ToString());

                                foreach (JObject item2 in jArray2)
                                {
                                    item_val2 = item2.GetValue("originActualAirportCode").ToString() + "|"
                                    + item2.GetValue("destinationActualAirportCode").ToString() + "|"
                                    + item2.GetValue("departureTerminal").ToString() + "|"
                                    + item2.GetValue("arrivalTerminal").ToString() + "|"
                                    + item2.GetValue("statusCode").ToString() + "|";

                                    JArray jArray3 = JArray.Parse("[\r\n  " + item2.GetValue("departureTime").ToString() + "\r\n]");

                                    foreach (JObject item3 in jArray3)
                                    {
                                        item_val3 = (item3.GetValue("actual") == null ? item3.GetValue("estimated").ToString() : item3.GetValue("actual")) + "|".ToString();

                                    }

                                    JArray jArray4 = JArray.Parse("[\r\n  " + item2.GetValue("arrivalTime").ToString() + "\r\n]");

                                    foreach (JObject item4 in jArray4)
                                    {
                                        item_val4 = (item4.GetValue("actual") == null ? item4.GetValue("estimated").ToString() : item4.GetValue("actual")).ToString();

                                    }
                                }

                                lstSearchResult.Add((item_val + item_val2 + item_val3 + item_val4));
                            }
                        }
                    }
                }
                return lstSearchResult;
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        public class SearchResult
        {
            public SearchResultRecords data { get; set; }
        }

        public class SearchResultRecords
        {
            public string airlineDesignator { get; set; }
            public string flightId { get; set; }
            public string flightNumber { get; set; }
            public string flightDate { get; set; }
            public flightRoute data { get; set; }
        }

        public class flightRoute
        {
            public string legNumber { get; set; }
            public string originActualAirportCode { get; set; }
            public string destinationActualAirportCode { get; set; }
            public string originPlannedAirportCode { get; set; }
            public string destinationPlannedAirportCode { get; set; }
            public string statusCode { get; set; }
            public string flightPosition { get; set; }
            public string totalTravelDuration { get; set; }
            public string travelDurationLeft { get; set; }
            public string isIrregular { get; set; }
            public string departureTerminal { get; set; }
            public string arrivalTerminal { get; set; }
            public departureTime data1 { get; set; }
            public arrivalTime data2 { get; set; }
            public operationalUpdate data3 { get; set; }
        }
        public class departureTime
        {
            public string schedule { get; set; }
            public string estimated { get; set; }
        }
        public class arrivalTime
        {
            public string schedule { get; set; }
            public string estimated { get; set; }
        }
        public class operationalUpdate
        {
            public string lastUpdated { get; set; }
        }


    }
}
