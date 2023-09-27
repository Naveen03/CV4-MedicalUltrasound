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
namespace UTScannerApp
{
    public partial class frmTGC : Form
    {

        public delegate void ApplyGCFilterEvtHandler(double[] tgcParam);
        public event ApplyGCFilterEvtHandler ApplyTGCFilter;
        protected OxyPlot.PlotModel thisPlotModel_;
        protected LineSeries thisLineSeries_;
        private double[] tgcParam_;
       
        public frmTGC()
        {
            InitializeComponent();
            InitializePlot();
            this.tgcParam_ = new double[8];
            clsConstant.Instance.isTGCOpen = false;
        }
        void InitializePlot()
        {
          
            thisPlotModel_ = new PlotModel
            {
                //Title = " LineProfile ",
                PlotType = PlotType.XY,
                TextColor = OxyColors.Black,
                PlotAreaBorderColor = OxyColors.White,
                TitleColor = OxyColors.Brown,
                SelectionColor = OxyColors.Violet,
                Background = OxyColors.Black,
                
            };
            this.thisLineSeries_ = new LineSeries();
            this.thisLineSeries_.Color = OxyColors.White;           
            for (int i = 0; i < 8; i++)
            {
                this.thisLineSeries_.Points.Add(new OxyPlot.DataPoint(150, i * 18.75));
            }

            thisLineSeries_.MarkerType = MarkerType.None;
            thisPlotModel_.Series.Add(this.thisLineSeries_);
            //ZoomToFit();
           
            this.xyPlot.Model = this.thisPlotModel_;
            
            this.thisPlotModel_.InvalidatePlot(true);
          
            Application.DoEvents();
            Application.DoEvents();
          
        }

        public void ApplyTGCValue(TrackBar tbControl)
        {
            var tbParam = tbControl;
            switch (tbParam.Name)
            {
                case "tbParam1":
                    numParam1.Value = tbParam.Value;
                    this.tgcParam_[0] = (double)numParam1.Value;
                    break;
                case "tbParam2":
                    numParam2.Value = tbParam.Value;
                    this.tgcParam_[1] = (double)numParam2.Value;
                    break;
                case "tbParam3":
                    numParam3.Value = tbParam.Value;
                    this.tgcParam_[2] = (double)numParam3.Value;
                    break;
                case "tbParam4":
                    numParam4.Value = tbParam.Value;
                    this.tgcParam_[3] = (double)numParam4.Value;
                    break;
                case "tbParam5":
                    numParam5.Value = tbParam.Value;
                    this.tgcParam_[4] = (double)numParam5.Value;
                    break;
                case "tbParam6":
                    numParam6.Value = tbParam.Value;
                    this.tgcParam_[5] = (double)numParam6.Value;
                    break;
                case "tbParam7":
                    numParam7.Value = tbParam.Value;
                    this.tgcParam_[6] = (double)numParam7.Value;
                    break;
                case "tbParam8":
                    numParam8.Value = tbParam.Value;
                    this.tgcParam_[7] = (double)numParam7.Value;
                    break;
            }
            if (this.xyPlot.Model != null)
            {
                this.xyPlot.Model = null;
                thisPlotModel_.Series.Clear();
                thisPlotModel_.Axes.Clear();
                this.thisLineSeries_.Points.Clear();
            }

            for (int i = 1; i <= 8; i++)
            {
                NumericUpDown matches = (NumericUpDown)this.Controls.Find("numParam" + i, true)[0];
                this.thisLineSeries_.Points.Add(new OxyPlot.DataPoint(150 - ((double)matches.Value * 0.06), i * 18.75));

            }


            thisLineSeries_.MarkerType = MarkerType.None;

            thisPlotModel_.Axes.Add(new OxyPlot.Axes.LinearAxis
            {
                Position = OxyPlot.Axes.AxisPosition.Right,
                EndPosition = 0,
                StartPosition = 1,
                TickStyle = OxyPlot.Axes.TickStyle.None,
                IsAxisVisible = false
            });
            thisPlotModel_.Axes.Add(new OxyPlot.Axes.LinearAxis
            {
                Position = OxyPlot.Axes.AxisPosition.Top,
                EndPosition = 0,
                StartPosition = 1,
                TickStyle = OxyPlot.Axes.TickStyle.None,
                IsAxisVisible = false
            });

            thisPlotModel_.Series.Add(this.thisLineSeries_);


            this.xyPlot.Model = this.thisPlotModel_;
            this.ZoomToFit();
            ApplyTGCFilter(this.tgcParam_);
        }
        private void tbParam_Scroll(object sender, EventArgs e)
        {
            ApplyTGCValue(sender as TrackBar);
        }
        public void ZoomToFit()
        {
            if (this.thisLineSeries_ != null)
            {
                this.thisPlotModel_.Axes[1].Zoom(130, 150);
                this.thisPlotModel_.Axes[0].Zoom(20, 150);
             
                this.RePlot(true);
            }

        }
        public void RePlot(bool fullRedraw)
        {
            if (this.thisLineSeries_ != null)
            {
                this.thisPlotModel_.InvalidatePlot(true);
            }
        }

        private void frmTGC_Shown(object sender, EventArgs e)
        {
            clsConstant.Instance.isTGCOpen = true;
        }

        private void frmTGC_FormClosing(object sender, FormClosingEventArgs e)
        {
            clsConstant.Instance.isTGCOpen = false;
        }
    }
}
