using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using OxyPlot;
using OxyPlot.Series;
using OxyPlot.WindowsForms;
using GraphLib;
namespace UTScannerApp
{
    public partial class ucViewer : UserControl
    {
        public delegate void ColorFlowCursorChangedEvtHandler();
        public event ColorFlowCursorChangedEvtHandler ColorflowCursorChanged;
        //  protected OxyPlot.Annotations.PolylineAnnotation polyLineCursor_;
        public double[,] imgData_;
        double[,] _MData;
        public int imgIdx_;
        private int scanModeIdx_;
        private int _aModeIdx = 0;
        private int _MIdx = 0;
        List<double[,]> lstImgData_;
        double min_;
        double max_;
        bool isTimerMode_;
        ucHeatMap ucBmode_;
        ucHeatMap ucMmode_;
        ucXYPlot ucXYPlot_;
        bool isLeftDirection_;
        double panelWidth;
        bool isInitial;
        public ucViewer()
        {
            InitializeComponent();
            InitializeControls();
            
            scanModeIdx_ = 0;
            isLeftDirection_ = false;
            isInitial = false;
        }

        void InitializeControls()
        {
            imgData_ = null;
            _MData = null;
            this.spltViewer.Panel2Collapsed = true;
            lstImgData_ = null;
            isTimerMode_ = false;
            ucBmode_ = new ucHeatMap();
            ucBmode_.ColorflowCursorChanged += UcBmode__ColorflowCursorChanged;
           // this.ucBmode_.AddMeasurementXYCursor();
            ucMmode_ = new ucHeatMap();
            ucXYPlot_ = new ucXYPlot();
            this.spltGraphPanel.Panel1Collapsed = true;
           
            this.ucBmode_.Dock = DockStyle.Fill;

            this.ucMmode_.Dock = DockStyle.Fill;
            this.ucXYPlot_.Dock = DockStyle.Fill;
            this.ucMmode_.ShowHideColorMap(false);

            this.splitMMode.Panel1.Controls.Add(ucBmode_);
            this.splitMMode.Panel2.Controls.Add(ucMmode_);
            this.splitAMode.Panel2.Controls.Add(ucXYPlot_);
            this.ucBmode_.BmodeCursorChanged += UcBmode__BmodeCursorChanged;
            this.ucBmode_.MouseClick += UcBmode__MouseClick;
            this.cmbScanModeSelecion.SelectedIndex = 0;

            this.lblSampleFreq.Visible = true;
            this.lblHospitalName.Visible = true;
            panelWidth=this.splitMMode.Panel1.Width;
        }

        private void UcBmode__ColorflowCursorChanged()
        {
            ColorflowCursorChanged();
        }

        private void UcBmode__MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Right)
            {
                this.ctxtMnu.Show();
            }
            else
            {
                this.ctxtMnu.Hide();
            }
        }
        public double[] GetColorflowCursorPoints()
        {
            return this.ucBmode_.GetRectangleCursorPoints();
        }
        public void ShowHideColorflowCursor(bool visiblity)
        {
            this.ucBmode_.SetRectangleCursorVisible(visiblity);
        }
        public void ShowHideBMesCursor(bool isVisible)
        {
            this.ucBmode_.ShowHideMeasurementXYCursor(isVisible);
        }
        private void UcBmode__BmodeCursorChanged(double[,] imagData, int aModeIdx)
        {
            _aModeIdx = aModeIdx;
            this.ucXYPlot_.Plot(imagData, aModeIdx, 0, imagData.GetLength(1));
        }

        public void loadImgData(List<double[,]> lstImgData)
        {
            if (lstImgData.Count > 0)
            {
                this.tmr.Stop();
                lstImgData_ = lstImgData;
                this.imgIdx_ = 0;
                //   this.tmr.Start();
                //   isTimerMode_ = true;
                this.btnPlayPause.Text = "Stop";
                //this.lblPatientName.Text = "Patient Name : " + clsConstant.Instance.paientName;
                //this.lblPatientID.Text = "Patient ID :" + clsConstant.Instance.patientID;
                //this.lblSampleFreq.Text = "SampleFreq :" + clsConstant.Instance.sampleFreq_ + " MHz";
                //this.lblHospitalName.Text = "Hospital :" + clsConstant.Instance.hospitalName;
                this.trkBar.Maximum = this.lstImgData_.Count;
               // this.spltGraphPanel.Panel1Collapsed = false;
                // this.spltViewer.Panel2Collapsed = false;
                loadImgData(lstImgData_[0]);
                this.lblSampleFreq.Visible = true;
                this.lblHospitalName.Visible = true;
                
            }

        }
        private void InitializeMData()
        {
            for (int idx = 0; idx < this._MData.GetLength(0); idx++)
            {
                for (int idxx = 0; idxx < this._MData.GetLength(1); idxx++)
                {
                    this._MData[idx, idxx] = 0;
                }
            }
        }
        public void loadImgData(double[,] imgData)
        {
            try
            {
                if (imgData != null)
                {
                    this.imgData_ = imgData;
                    if (this._MData != null)
                        _MData = null;

                    _MData = new double[this.imgData_.GetLength(0), this.imgData_.GetLength(1)];
                    // InitializeMData();
                    this.lblFrameIdx.Text = (this.imgIdx_ + 1).ToString();
                    this.ucBmode_.ClearPlotSeries();
                    this.ucBmode_.Plot2DData(imgData);
                    this.ucBmode_.ShowHideColorMap(true);
                    this.ucBmode_.SetEllipseCursorVisible(false);
                   // this.ucBmode_.Dock = DockStyle.Fill;
                    if (!isInitial)
                    {
                        panelWidth = this.splitMMode.Panel1.Width;
                        isInitial = true;

                        this.ucBmode_.Dock = DockStyle.None;
                        ucBmode_.Width = (int)Math.Round(panelWidth / 2);
                        ucBmode_.Height = this.splitMMode.Panel1.Height;
                        this.ucBmode_.SetColorScaleWidth();

                    }
                    //if (this.splitAMode.Panel2Collapsed || this.scanModeIdx_ == 3)
                    //{

                    //    this.ucBmode_.Dock = DockStyle.None;
                    //    ucBmode_.Width = (int)Math.Round(panelWidth / 2);
                    //    ucBmode_.Height = this.splitMMode.Panel1.Height-1;
                    //}
                    //else
                    //{
                    //   this.ucBmode_.Dock = DockStyle.Fill;
                    //}

                }
            }
            catch(Exception xptn)
            {

            }
        }
        public void ResetAspect( bool isFill)
        {

            if (isFill)
            {
                this.ucBmode_.Dock = DockStyle.Fill;
                this.ucBmode_.SetColorScaleWidth();
            }
            else {
                       this.ucBmode_.Dock = DockStyle.None;
                        ucBmode_.Width = this.splitMMode.Panel1.Width / 2;
                        ucBmode_.Height = this.splitMMode.Panel1.Height;
                this.ucBmode_.SetColorScaleWidth();
            }
        }
        public void LoadColorFlowData(double[,] imgData, List<double[]> overloadData)
        {
              this.ucBmode_.SetRBColorMap();
            this.ucBmode_.Plot2DDatawithColorFlow(imgData, overloadData);
        }

        public void ApplyManualColorScale(bool isRGB, int min, int max)
        {
            this.ucBmode_.SetManualColorMap(min, max, isRGB);
        }
        public void SetAutoColorScale(bool isRGB)
        {
            this.ucBmode_.SetAutoColorMap( isRGB);
        }
        public void ResetGraph()
        {
            this.ucBmode_.ZoomToFit();
        }
        public Bitmap GetPlotImage()
        {
            return this.ucBmode_.GetPlotImage();
        }
        private void btnReset_Click(object sender, EventArgs e)
        {
            ResetGraph();
        }
        
        public void LoadFramebyIndex(int frameIndex)
        {
            try
            {
                if (!isTimerMode_)
                {
                    if (frameIndex < this.lstImgData_.Count)
                    {
                        this.imgIdx_ = frameIndex;
                        this.loadImgData(this.lstImgData_[this.imgIdx_]);
                    }
                }
            }
            catch (Exception xptn)
            { }
        }
        public void drawNeedle(double angle)
        {
            this.ucBmode_.drawNeedle(angle);
        }
        public void CleartheNeedle()
        {
            this.ucBmode_.CleartheNeedle();
        }
        public void SaveGraph()
        {
            this.sfd.Filter = "Png Image (.png)|*.png";
            this.sfd.DefaultExt = ".png";
            this.sfd.InitialDirectory = Application.StartupPath;
            if (this.sfd.ShowDialog() == DialogResult.OK)
            {
                this.ucBmode_.SavePlotImage(sfd.FileName);
                MessageBox.Show("Saved..");
            }
        }
        private void btnSave_Click(object sender, EventArgs e)
        {
            SaveGraph();
        }
        public void StartMeasurementCursor(bool isEnable)
        {
            this.ucBmode_.StartMeasurementCursor(isEnable);
        }
        public void ShowHideMeasurementCursor(bool isVisible)
        {
            this.ucBmode_.SetEllipseCursorVisible(isVisible);
           
        }
        public void SetScanMode(int modeIdx)
        {
            try
            {
                scanModeIdx_ = modeIdx;
                switch (modeIdx)
                {
                    case 0://B
                        this.splitAMode.Panel1Collapsed = false;
                        this.splitAMode.Panel2Collapsed = true;
                        this.splitMMode.Panel2Collapsed = true;
                        this.ucBmode_.ShowHideCursor(false);
                        //this.ucBmode_.Dock = DockStyle.Fill;
                        this.ucBmode_.Dock = DockStyle.None;
                        ucBmode_.Width =(int) Math.Round(panelWidth / 2);
                        ucBmode_.Height = this.splitMMode.Panel1.Height;
                        break;
                    case 1://B-A
                        this.splitAMode.Panel1Collapsed = false;
                        this.splitAMode.Panel2Collapsed = false;
                        this.splitMMode.Panel2Collapsed = true;
                        this.ucBmode_.ShowHideCursor(true);
                        this.ucXYPlot_.ShowHideCursor(true);
                        this.ucBmode_.Dock = DockStyle.None;
                        ucBmode_.Width = (int)Math.Round(panelWidth / 3);
                        ucBmode_.Height = this.splitMMode.Panel1.Height;

                        break;
                    case 2://A
                        this.splitAMode.Panel2Collapsed = false;
                        this.splitAMode.Panel1Collapsed = true;
                        this.ucBmode_.ShowHideCursor(true);
                        this.ucXYPlot_.ShowHideCursor(true);
                        this.ucBmode_.Dock = DockStyle.Fill;
                        break;
                    case 3://B-M-A
                        this.splitAMode.Panel1Collapsed = false;
                        this.splitAMode.Panel2Collapsed = false;
                        this.splitMMode.Panel2Collapsed = false;
                        this.splitMMode.SplitterDistance = (int)Math.Ceiling(this.splitMMode.Width / 2.0);
                        this.ucBmode_.ShowHideCursor(true);
                        this.ucXYPlot_.ShowHideCursor(true);
                        this.tmrM_Mode.Start();
                        this.ucBmode_.Dock = DockStyle.None;
                        ucBmode_.Width = (int)Math.Round(panelWidth / 2);
                        ucBmode_.Height = this.splitMMode.Panel1.Height;

                        break;
                    case 4://B-M
                        this.splitMMode.Panel2Collapsed = false;
                        this.splitMMode.Panel1Collapsed = false;
                        this.splitMMode.SplitterDistance = (int)Math.Ceiling(this.splitMMode.Width / 2.0);
                        this.splitAMode.Panel2Collapsed = true;
                        this.ucBmode_.ShowHideCursor(false);
                        this.tmrM_Mode.Start();
                        this.ucBmode_.Dock = DockStyle.Fill;
                        break;
                    case 5://M
                        this.splitMMode.Panel2Collapsed = false;
                        this.splitAMode.Panel1Collapsed = false;
                        this.splitAMode.Panel2Collapsed = true;
                        this.splitMMode.Panel1Collapsed = true;
                        this.ucBmode_.ShowHideCursor(false);
                        this.tmrM_Mode.Start();
                        this.ucBmode_.Dock = DockStyle.Fill;
                        break;
                }
            }
            catch (Exception xptn)
            {

            }
        }

        private void tmrM_Mode_Tick(object sender, EventArgs e)
        {
            if (this._MData != null && scanModeIdx_ > 2)
            {
                if (_MIdx < this._MData.GetLength(0))
                {
                    for (int idx = 0; idx < this._MData.GetLength(1); idx++)
                    {
                        this._MData[_MIdx, idx] = this.imgData_[this._aModeIdx, idx];
                    }
                    this.ucMmode_.axes_.ShowHideYAxis(false);
                    this.ucMmode_.ShowHideColorMap(false);
                    this.ucMmode_.Plot2DData(this._MData);
                    _MIdx++;
                }
                else
                {
                    _MIdx = 0;
                }
            }
        }

        private void btnDirection_Click(object sender, EventArgs e)
        {
            if(!isLeftDirection_)
            {               
                this.btnDirection.BackgroundImage = new Bitmap(Application.StartupPath + "\\Left.png");
                isLeftDirection_ = true;
            }    
            else
            {
                isLeftDirection_ = false;
                this.btnDirection.BackgroundImage = new Bitmap(Application.StartupPath + "\\Right.png");
            }
        }
    }
}
