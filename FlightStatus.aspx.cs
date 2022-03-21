using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.IO;
using System.Data;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Web.Services;


namespace FlightStatusCheck
{
    public partial class FlightStatus : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            ListItem lst;

            DateTime dateValue = DateTime.Now.AddDays(-1);

            lst = new ListItem();
            lst.Value = dateValue.Year.ToString() + "-" + (dateValue.Month.ToString().Length == 1 ? "0" + dateValue.Month.ToString() : dateValue.Month.ToString()) + "-" + dateValue.Day.ToString();
            lst.Text = "Yesterday, " + dateValue.Day.ToString() + " " + dateValue.ToString("MMM") + " " + dateValue.Year.ToString();
            ddlDate.Items.Add(lst);

            dateValue = DateTime.Now;

            lst = new ListItem();
            lst.Value = dateValue.Year.ToString() + "-" + (dateValue.Month.ToString().Length == 1 ? "0" + dateValue.Month.ToString() : dateValue.Month.ToString()) + "-" + dateValue.Day.ToString();
            lst.Text = "Today, " + dateValue.Day.ToString() + " " + dateValue.ToString("MMM") + " " + dateValue.Year.ToString();
            ddlDate.Items.Add(lst);
            ddlDate.SelectedValue = lst.Value;


            dateValue = DateTime.Now.AddDays(1);

            lst = new ListItem();
            lst.Value = dateValue.Year.ToString() + "-" + (dateValue.Month.ToString().Length == 1 ? "0" + dateValue.Month.ToString() : dateValue.Month.ToString()) + "-" + dateValue.Day.ToString();
            lst.Text = "Tomorrow, " + dateValue.Day.ToString() + " " + dateValue.ToString("MMM") + " " + dateValue.Year.ToString();
            ddlDate.Items.Add(lst);

        }
    }
}