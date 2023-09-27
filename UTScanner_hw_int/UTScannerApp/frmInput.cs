using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace UTScannerApp
{
    public partial class frmInput : WeifenLuo.WinFormsUI.Docking.DockContent
    {
        public delegate void LoadImageEvtHandler();
        public event LoadImageEvtHandler ImportImage;
        public delegate void TGCEvtHandler();
        public event TGCEvtHandler LoadTGC;

        public delegate void ColorFlowEvtHandler();
        public event ColorFlowEvtHandler ApplyColorFlow;

        public delegate void colorScaleChanged(bool isRGB, int min, int max);
        public event colorScaleChanged ApplyColorScale;
        public delegate void AutoColorScaleChanged(bool isRGB);
        public event AutoColorScaleChanged ApplyAutoColorScale;

        public delegate void DrawNeedleEvtHandler(double angle);
        public event DrawNeedleEvtHandler NeedleEnable;

        public delegate void ShowApplicaionEvtHandler(bool isEnable);
        public event ShowApplicaionEvtHandler ShowApplicaion;

        public delegate void ApplyEnhancementEvtHandler(int enhanceID);
        public event ApplyEnhancementEvtHandler ApplyEnhancementFilter;

        public delegate void GainChangedEvtHandler(double gain);
        public event GainChangedEvtHandler ChangedGain;

        public delegate void DepthChangedEvtHandler(double depth);
        public event GainChangedEvtHandler ChangedDepth;

        public delegate void GammaCurveChangedEvtHandler(double[] curvePts);
        public event GammaCurveChangedEvtHandler GammaChanged;

        public delegate void ApplyDeSpeckleEvtHandler();
        public event ApplyDeSpeckleEvtHandler ApplyDeSpeckleFilter;

        public delegate void ColorFlowCursorChangedEvtHandler();
        public event ColorFlowCursorChangedEvtHandler ShwColorFlowCursor;

        public delegate void ApplyDynamicEvtHandler(double dynamicParam);
        public event ApplyDynamicEvtHandler ApplyDynamicFilter;

        public delegate void DoGPUProcessEvtHandler();
        public event DoGPUProcessEvtHandler doGPUProcess;

        public bool isEnableNeedle;
        public bool isEnableApplication;

        ucGraph ucGammaCurve_;
        frmBGammaCurve frmBGammaCurve_;
        public frmInput()
        {
            InitializeComponent();
            isEnableNeedle = false;
            isEnableApplication = false;
            this.CloseButtonVisible = false;

            ucGammaCurve_ = new ucGraph(false);
            this.grbGammaCurve.Controls.Add(ucGammaCurve_);
            ucGammaCurve_.Dock = DockStyle.Fill;
            ucGammaCurve_.xyPlot.MouseDoubleClick += XyPlot_MouseDoubleClick; ;
            frmBGammaCurve_ = new frmBGammaCurve();
            frmBGammaCurve_.CurveChanged += gammaCurveChanged;
        }
        void gammaCurveChanged(OxyPlot.Series.LineSeries lineSeries)
        {
            this.ucGammaCurve_.SetLineSeries(lineSeries);
            double[] pts = new double[lineSeries.Points.Count];
            int idx = 0;
            foreach (var pt in lineSeries.Points)
            {
                pts[idx++] = pt.Y;
            }
            GammaChanged(pts);
        }

        private void XyPlot_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            frmBGammaCurve_.ShowDialog();
        }

        private void btnLoad_Click(object sender, EventArgs e)
        {
            ImportImage();
        }

        private void btnTGC_Click(object sender, EventArgs e)
        {
            LoadTGC();
        }

        private void tbGain_Scroll(object sender, EventArgs e)
        {
            numGain.Value = tbGain.Value;
        }
        public void SetGain(int gain)
        {
            this.tbGain.Value = gain;
            numGain.Value = gain;
        }
        private void numGain_ValueChanged(object sender, EventArgs e)
        {
            ChangedGain((double)this.numGain.Value);
        }

        private void tbDynamic_Scroll(object sender, EventArgs e)
        {
            numDynamic.Value = (Decimal)(tbDynamic.Value / 100.0);
        }

        private void btnNeedle_Click(object sender, EventArgs e)
        {
            if (isEnableNeedle)
            {
                isEnableNeedle = false;
                this.btnNeedle.Text = "Needle Enable";
            }
            else
            {
                isEnableNeedle = true;
                this.btnNeedle.Text = "Needle Disable";
            }

            NeedleEnable((double)this.numNeedleAngle.Value);
        }

        private void numNeedleAngle_ValueChanged(object sender, EventArgs e)
        {
            isEnableNeedle = true;
            NeedleEnable((double)this.numNeedleAngle.Value);
        }

        private void btnApplication_Click(object sender, EventArgs e)
        {
            if (isEnableApplication)
                this.isEnableApplication = false;
            else
                this.isEnableApplication = true;

            ShowApplicaion(this.isEnableApplication);
        }

        private void btnEnhancement_Click(object sender, EventArgs e)
        {
            //int s_option = (int)this.numFilterID.Value; //choosing despekling option 0-2
            //int niter = (int)this.numNiter.Value; //number of iterations 1-20
            //float kappa = (float)this.numKappa.Value; // kappa for despekling 1-20
            //float lambda = (float)this.numLambda.Value; // lambda for despekling 0-1
            //float clahe_clip = 1.5f; // clip value for enhancement 0-2
            if (rbtnLowEnhance.Checked)
                ApplyEnhancementFilter(0);
            else if (rbtnMediumEnhance.Checked)
                ApplyEnhancementFilter(1);
            else if (rbtnHighEnhance.Checked)
                ApplyEnhancementFilter(3);
        }

        private void btnColorflow_Click(object sender, EventArgs e)
        {
            ApplyColorFlow();
        }

        private void btnColorFlowCursor_Click(object sender, EventArgs e)
        {
            ShwColorFlowCursor();
        }

        private void numDepth_ValueChanged(object sender, EventArgs e)
        {
            ChangedDepth((double)this.numDepth.Value);
        }

        private void rbtnRGBManual_CheckedChanged(object sender, EventArgs e)
        {
            if (rbtnRGBManual.Checked)
            {
                this.pnlRGB.Enabled = true;

            }
        }

        private void rbtnRGBAuto_CheckedChanged(object sender, EventArgs e)
        {
            if (rbtnRGBAuto.Checked)
            {
                this.pnlRGB.Enabled = false;
                ApplyAutoColorScale(true);

            }
        }

        private void rbtnGrayAuto_CheckedChanged(object sender, EventArgs e)
        {
            if (rbtnGrayAuto.Checked)
            {
                this.pnlGray.Enabled = false;
                ApplyAutoColorScale(false);
            }
        }

        private void rbtnGrayManual_CheckedChanged(object sender, EventArgs e)
        {
            if (rbtnGrayManual.Checked)
            {
                this.pnlGray.Enabled = true;
            }
        }

        private void numRGBMax_ValueChanged(object sender, EventArgs e)
        {
            ApplyColorScale(true, (int)this.numRGBMin.Value, (int)this.numRGBMax.Value);
        }

        private void numGrayMin_ValueChanged(object sender, EventArgs e)
        {
            ApplyColorScale(false, (int)this.numGrayMin.Value, (int)this.numGrayMax.Value);
        }

        private void rbtnLowEnhance_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void rbtnMediumEnhance_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void rbtnHighEnhance_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void btnDeSpeckle_Click(object sender, EventArgs e)
        {
            ApplyDeSpeckleFilter();
        }

        private void numDynamic_ValueChanged(object sender, EventArgs e)
        {
            if (numDynamic.Value != (Decimal)(tbDynamic.Value / 100.0))
            {
                this.tbDynamic.Value = (int)(numDynamic.Value * 100);
            }
            ApplyDynamicFilter((double)this.numDynamic.Value);
        }

        private void btnGpu_Click(object sender, EventArgs e)
        {
            doGPUProcess();
        }
    }
}
