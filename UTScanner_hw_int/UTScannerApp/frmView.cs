
﻿using System;
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
    public partial class frmView : WeifenLuo.WinFormsUI.Docking.DockContent
    {
        public delegate void CaptureFrameEvtHandler(double[,] currentFrameData, Bitmap currentImg);
        public event CaptureFrameEvtHandler SaveCurrentFrame;

        public delegate void ColorFlowCursorChangedEvtHandler();
        public event ColorFlowCursorChangedEvtHandler ColorflowCursorChanged;

        public List<ucExternalView> extViewList_;
        public ucViewer uc2DView_;
        private List<double[,]> lstImgData_;
        public int imgIdx_;
        int splitDist;
        private bool isEnableMeasurementCursor_;
        private bool isEnableLinearMeasurementCursor_;
        bool isLeftDirection_;
        public frmView()
        {
            InitializeComponent();
            InitializeGUI();
            this.CloseButtonVisible = false;
            this.tip.SetToolTip(this.btnMeasurement, "Measurement");
            this.tip.SetToolTip(this.btnReset, "Reset");
            this.tip.SetToolTip(this.btnUndo, "Undo");
            this.tip.SetToolTip(this.btnSave, "Save");
            this.tip.SetToolTip(this.btnCapture, "Capture");
            isEnableMeasurementCursor_ = false;
            isEnableLinearMeasurementCursor_ = false;
            splitDist = 0;
        }
        void InitializeGUI()
        {
            lstImgData_ = new List<double[,]>();
            this.splitBase.Panel2Collapsed = true;
            this.splitTop.Panel2Collapsed = true;
            this.splitBottom.Panel2Collapsed = true;
            this.splitV.Panel2Collapsed = true;
            this.uc2DView_ = new ucViewer();
            this.uc2DView_.ColorflowCursorChanged += Uc2DView__ColorflowCursorChanged;
            this.SplitParant.Panel1Collapsed = true;
            this.uc2DView_.Dock = DockStyle.Fill;
            this.splitTop.Panel1.Controls.Add(uc2DView_);
            this.splitTop.Dock = DockStyle.Fill;
            extViewList_ = new List<ucExternalView>();
            extViewList_.Add(new ucExternalView());
            extViewList_.Add(new ucExternalView());
            extViewList_.Add(new ucExternalView());

            foreach (var ucExtView in extViewList_)
            {
                ucExtView.Dock = DockStyle.Fill;
                ucExtView.ucHeatMap_.isExternalView_ = true;
            }

            this.splitTop.Panel2.Controls.Add(extViewList_[0]);
            this.splitBottom.Panel1.Controls.Add(extViewList_[1]);
            this.splitBottom.Panel2.Controls.Add(extViewList_[2]);

            this.cmbViewLayout.SelectedIndex = 0;
            this.cmbScanModeSelecion.SelectedIndex = 0;
        }

        private void Uc2DView__ColorflowCursorChanged()
        {
            ColorflowCursorChanged();
        }

        public void SetStatus(string status)
        {
            this.lblStatus.Text = status;
        }
        public void SetScanMode(int modeIdx)
        {
            if (modeIdx < this.cmbScanModeSelecion.Items.Count)
            {
                this.cmbScanModeSelecion.SelectedIndex = modeIdx;
            }
        }
        public double[] GetColorflowCursorPoints()
        {
            return this.uc2DView_.GetColorflowCursorPoints();
        }
        public void ShowHideColorflowCursor(bool visiblity)
        {
            this.uc2DView_.ShowHideColorflowCursor(visiblity);
        }
        private void btnReset_Click(object sender, EventArgs e)
        {
            this.uc2DView_.ResetGraph();
        }
        public void loadImgData(List<double[,]> lstImgData)
        {
            this.splitV.Panel2Collapsed = false;
            this.SplitParant.Panel1Collapsed = false;
            this.lstImgData_ = lstImgData;
            this.trkBar.Maximum = this.lstImgData_.Count;
            this.lblPatientName.Text = "Patient Name : " + clsConstant.Instance.paientName;
            this.lblPatientID.Text = "Patient ID :" + clsConstant.Instance.patientID;
            this.lblSampleFreq.Text = "SampleFreq :" + clsConstant.Instance.sampleFreq_ + " MHz";
            this.lblHospitalName.Text = "Hospital :" + clsConstant.Instance.hospitalName;

            this.uc2DView_.loadImgData(lstImgData);

            this.cmbViewLayout.SelectedIndex = 0;
            this.uc2DView_.ResetGraph();
        }
        private void btnSave_Click(object sender, EventArgs e)
        {
            this.uc2DView_.SaveGraph();
        }
        public void LoadFramebyIndex(int frameIndex)
        {
            if (frameIndex < this.lstImgData_.Count)
                this.trkBar.Value = frameIndex;
        }
        public void ViewLayoutbyIdx(int LayoutIdx)
        {
            if (cmbViewLayout.Items.Count > LayoutIdx && LayoutIdx < this.lstImgData_.Count)
                this.cmbViewLayout.SelectedIndex = LayoutIdx;
        }
        void LoadImgtoLayout()
        {
            try
            {
                if (cmbViewLayout.SelectedIndex > 0)
                {

                    for (int idx = 0; idx < cmbViewLayout.SelectedIndex; idx++)
                    {
                        this.imgIdx_ += (idx + 1);
                        if (imgIdx_ < this.lstImgData_.Count)
                        {
                            this.extViewList_[idx].loadImgData(this.lstImgData_[this.imgIdx_], idx + 1);
                            if (idx == 1)
                            {
                                this.imgIdx_++;
                                if (imgIdx_ < this.lstImgData_.Count)
                                    this.extViewList_[idx + 1].loadImgData(this.lstImgData_[this.imgIdx_], idx + 2);
                            }
                        }
                    }
                }
            }
            catch (Exception xptn)
            {

            }
        }

        private void trkBar_Scroll(object sender, EventArgs e)
        {
            this.imgIdx_ = this.trkBar.Value;
            this.uc2DView_.LoadFramebyIndex(this.imgIdx_);
            LoadImgtoLayout();
        }

        private void cmbScanModeSelecion_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cmbScanModeSelecion.SelectedIndex >= 0)
                this.uc2DView_.SetScanMode(cmbScanModeSelecion.SelectedIndex);
        }
        public void LoadColorFlowData(double[,] imgData, List<double[]> overloadData)
        {
            this.uc2DView_.LoadColorFlowData(imgData, overloadData);
        }
        public void ApplyManualColorScale(bool isRGB, int min, int max)
        {
            this.uc2DView_.ApplyManualColorScale(isRGB, min, max);
        }
        public void SetAutoColorScale(bool isRGB)
        {
            this.uc2DView_.SetAutoColorScale(isRGB);
        }
        private void cmbViewLayout_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                this.uc2DView_.ResetAspect(true);
                switch (cmbViewLayout.SelectedIndex)
                {
                    case 0:
                        this.splitBase.Panel2Collapsed = true;
                        this.splitTop.Panel2Collapsed = true;
                        this.splitBottom.Panel2Collapsed = true;
                        extViewList_[0].ResizeWindow(false);
                        extViewList_[1].ResizeWindow(false);
                        extViewList_[2].ResizeWindow(false);

                        this.uc2DView_.ResetAspect(false);
                        break;
                    case 1:
                        this.splitTop.Panel2Collapsed = false;
                        if (splitDist == 0)
                        {
                            splitDist = this.splitTop.SplitterDistance;
                        }
                        this.splitTop.SplitterDistance = splitDist + 20;//+ 40;
                        this.splitBase.Panel2Collapsed = true;
                        extViewList_[0].ResizeWindow(false);
                        extViewList_[1].ResizeWindow(false);
                        extViewList_[2].ResizeWindow(false);
                        this.uc2DView_.ResetAspect(true);
                        break;
                    case 2:
                        //    this.splitTop.Panel2Collapsed = false;
                        //    this.splitBase.Panel2Collapsed = false;
                        //    this.splitBottom.Panel2Collapsed = true;
                        //    extViewList_[0].ResizeWindow(true);
                        //    extViewList_[1].ResizeWindow(true);                    
                        //    extViewList_[2].ResizeWindow(false);
                        //    break;
                        //case 3:
                        this.splitTop.Panel2Collapsed = false;
                        this.splitBase.Panel2Collapsed = false;
                        this.splitBottom.Panel2Collapsed = false;
                        extViewList_[0].ResizeWindow(true);
                        extViewList_[1].ResizeWindow(true);
                        extViewList_[2].ResizeWindow(true);
                        this.uc2DView_.ResetAspect(false);
                        break;
                }
                LoadImgtoLayout();
            }
            catch (Exception xptn)
            {

            }
        }

        private void btnMeasurement_Click(object sender, EventArgs e)
        {
            if (isEnableMeasurementCursor_)
                isEnableMeasurementCursor_ = false;
            else
                isEnableMeasurementCursor_ = true;

            if (this.cmbViewLayout.SelectedIndex == 1)
                this.extViewList_[0].ShowHideMeasurementCursor(isEnableMeasurementCursor_);
            else if (this.cmbViewLayout.SelectedIndex == 2)
            {
                foreach (var viewLyt in this.extViewList_)
                    viewLyt.ShowHideMeasurementCursor(isEnableMeasurementCursor_);
            }
            this.uc2DView_.ShowHideMeasurementCursor(isEnableMeasurementCursor_);



        }

        private void btnUndo_Click(object sender, EventArgs e)
        {
            this.uc2DView_.LoadFramebyIndex(this.imgIdx_);
        }

        private void btnCapture_Click(object sender, EventArgs e)
        {
            SaveCurrentFrame(this.uc2DView_.imgData_, this.uc2DView_.GetPlotImage());
        }
        public void ShowHideLinearMeasurement()
        {
            if (!isEnableLinearMeasurementCursor_)
                isEnableLinearMeasurementCursor_ = true;
            else
                isEnableLinearMeasurementCursor_ = false;
            if (this.cmbViewLayout.SelectedIndex == 1)
                this.extViewList_[0].StartMeasurementCursor(isEnableLinearMeasurementCursor_);
            else if (this.cmbViewLayout.SelectedIndex == 2)
            {
                foreach (var viewLyt in this.extViewList_)
                    viewLyt.StartMeasurementCursor(isEnableLinearMeasurementCursor_);
            }
            this.uc2DView_.StartMeasurementCursor(isEnableLinearMeasurementCursor_);
        }
        private void btnStartmeasurement_Click(object sender, EventArgs e)
        {
            //if (!isEnableLinearMeasurementCursor_)
            //    isEnableLinearMeasurementCursor_ = true;
            //else
            //    isEnableLinearMeasurementCursor_ = false;
            //if(this.cmbViewLayout.SelectedIndex==1)
            //   this.extViewList_[0].StartMeasurementCursor(isEnableLinearMeasurementCursor_);
            //else if (this.cmbViewLayout.SelectedIndex == 2)
            //{
            //    foreach(var viewLyt in this.extViewList_)
            //        viewLyt.StartMeasurementCursor(isEnableLinearMeasurementCursor_);
            //}
            //    this.uc2DView_.StartMeasurementCursor(isEnableLinearMeasurementCursor_);

            ShowHideLinearMeasurement();
        }

        private void btnDirection_Click(object sender, EventArgs e)
        {
            if (!isLeftDirection_)
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
