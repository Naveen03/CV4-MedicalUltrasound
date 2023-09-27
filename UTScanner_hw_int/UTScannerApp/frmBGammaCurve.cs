using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Xml;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;
using OxyPlot.Series;
using Newtonsoft.Json;
namespace UTScannerApp
{
    public partial class frmBGammaCurve : Form
    {
        ucGraph ucGammaCurve_;
        clsCurveList gammaCurveList;
        public delegate void CurveChangedEvtHandler(LineSeries lnSeries);
        public event CurveChangedEvtHandler CurveChanged;
        public frmBGammaCurve()
        {
            InitializeComponent();
            ucGammaCurve_ = new ucGraph(true);
            this.splitContainer1.Panel1.Controls.Add(ucGammaCurve_);
            ucGammaCurve_.Dock = DockStyle.Fill;

            if(File.Exists( clsConstant.Instance.gammaCurveFile))
            {
                string jsonData = File.ReadAllText(clsConstant.Instance.gammaCurveFile);
                this.gammaCurveList = JsonConvert.DeserializeObject<clsCurveList>(jsonData);
            }

            UpdateEffect();



        }
        void UpdateEffect()
        {
            this.cmbEffect.Items.Clear();
            this.cmbEffect.Items.Add("Custom");
            if (this.gammaCurveList != null)
            {
                foreach (var curve in this.gammaCurveList.curveList)
                {
                    this.cmbEffect.Items.Add(curve.curveName);
                }
            }
            this.cmbEffect.SelectedIndex = this.cmbEffect.Items.Count-1;
        }
        private void cmbEffect_SelectedIndexChanged(object sender, EventArgs e)
        {
            if(cmbEffect.SelectedIndex>0)
            {
                this.ucGammaCurve_.SetCurve(this.gammaCurveList.curveList[cmbEffect.SelectedIndex-1].curveXPoints, this.gammaCurveList.curveList[cmbEffect.SelectedIndex - 1].curveYPoints);
            }
            else
            {
                this.ucGammaCurve_.SetLinear();
            }
        }

        private void btnSet_Click(object sender, EventArgs e)
        {
            CurveChanged(this.ucGammaCurve_.lnSeries_);
        }

        private void btnLinear_Click(object sender, EventArgs e)
        {
          if(cmbEffect.SelectedIndex >0)
            {
                if (MessageBox.Show("Do you want Remove?", "Info", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    this.gammaCurveList.curveList.RemoveAt(cmbEffect.SelectedIndex - 1);
                    SaveCurve();
                    this.UpdateEffect();
                }
            }
        }

        void SaveCurve()
        {
            string jData = JsonConvert.SerializeObject(this.gammaCurveList);
            File.WriteAllText(clsConstant.Instance.gammaCurveFile, jData);
        }
        private void btnSave_Click(object sender, EventArgs e)
        {
            if (this.gammaCurveList == null)
            {
                this.gammaCurveList = new clsCurveList();
                this.gammaCurveList.curveList = new List<clsCurve>();
            }
            clsConstant.Instance.CurrentCurveName = this.cmbEffect.Text.Equals("Custom") ? "Type" + (this.gammaCurveList.curveList.Count + 1) : this.cmbEffect.Text;
            AddGamaCurveDialog addCurveDialog = new AddGamaCurveDialog();
          
            addCurveDialog.ShowDialog();
           
            if (String.IsNullOrEmpty(clsConstant.Instance.CurrentCurveName) || String.IsNullOrWhiteSpace(clsConstant.Instance.CurrentCurveName))
            {
                clsConstant.Instance.CurrentCurveName = "Type" + (this.gammaCurveList.curveList.Count + 1);
            }
            double[] xpoints = new double[this.ucGammaCurve_.lnSeries_.Points.Count];
            double[] ypoints = new double[this.ucGammaCurve_.lnSeries_.Points.Count];
            int pIdx = 0;
            foreach(var pts in this.ucGammaCurve_.lnSeries_.Points)
            {
                xpoints[pIdx] = pts.X;
                ypoints[pIdx++] = pts.Y;
            }
            this.gammaCurveList.curveList.Add(new clsCurve() { curveName = clsConstant.Instance.CurrentCurveName,curveXPoints = xpoints,curveYPoints=ypoints });

            SaveCurve();
            UpdateEffect();
        }
    }
}
