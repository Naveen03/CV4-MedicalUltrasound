using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using GraphLib;
namespace UTScannerApp
{
    public partial class ucExternalView : UserControl
    {
        double[,] imgData_;
        public ucHeatMap ucHeatMap_;
        public ucExternalView()
        {
            InitializeComponent();           
            ucHeatMap_ = new ucHeatMap();
            this.spltGraphPanel.Panel1Collapsed = true;
            this.ucHeatMap_.Dock = DockStyle.Fill;
            this.spltGraphPanel.Panel2.Controls.Add(ucHeatMap_);

        }
        public void loadImgData(double[,] imgData, int frameIdx)
        {
            this.imgData_ = imgData;
            this.lblFrameIdx.Text = $"Frame : {frameIdx}";
            this.ucHeatMap_.ClearPlotSeries();
            this.ucHeatMap_.Plot2DData(imgData);
            this.ucHeatMap_.ShowHideColorMap(false);
            this.spltGraphPanel.Panel1Collapsed = true;
            
        }
        public void ResizeWindow( bool isResize)
        {
            if (isResize)
            {

                this.ucHeatMap_.Dock = DockStyle.None;
                ucHeatMap_.Width = this.spltGraphPanel.Panel2.Width / 2;
                ucHeatMap_.Height = this.spltGraphPanel.Panel2.Height;
            }
            else
            {
                this.ucHeatMap_.Dock = DockStyle.Fill;
            }
        }
        public void StartMeasurementCursor(bool isEnable)
        {
            this.ucHeatMap_.StartMeasurementCursor(isEnable);
        }
        public void ShowHideMeasurementCursor(bool isVisible)
        {
            this.ucHeatMap_.SetEllipseCursorVisible(isVisible);

        }
    }
}
