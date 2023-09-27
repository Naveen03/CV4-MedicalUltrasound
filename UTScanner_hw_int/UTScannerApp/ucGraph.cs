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
using OxyPlot.Annotations;
namespace UTScannerApp
{
    public partial class ucGraph : UserControl
    {
        protected OxyPlot.PlotModel thisPlotModel_;
        public LineSeries lnSeries_;
        protected PointAnnotation[] pointAnnotation_;
        bool isfrmGammaCurve_;
        int selectedPointIdx = 0;
        bool isDrag;
        public ucGraph(bool isfrmGammaCurve)
        {
            InitializeComponent();
            InitializePlot(isfrmGammaCurve);
            isDrag = false;
        }
        void InitializePlot(bool isfrmGammaCurve)
        {
            isDrag = false;
            isfrmGammaCurve_ = isfrmGammaCurve;
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
            this.lnSeries_ = new LineSeries();
           
            this.lnSeries_.Points.Add(new OxyPlot.DataPoint (0, 0));
            this.lnSeries_.Points.Add(new OxyPlot.DataPoint(12.5, 12.5));
            this.lnSeries_.Points.Add(new OxyPlot.DataPoint(25, 25));
            this.lnSeries_.Points.Add(new OxyPlot.DataPoint(37.5, 37.5));
            this.lnSeries_.Points.Add(new OxyPlot.DataPoint(50, 50));
            this.lnSeries_.Points.Add(new OxyPlot.DataPoint(62.5, 62.5));
            this.lnSeries_.Points.Add(new OxyPlot.DataPoint(75, 75));
            this.lnSeries_.Points.Add(new OxyPlot.DataPoint(87.5, 87.5));
            this.lnSeries_.Points.Add(new OxyPlot.DataPoint(100, 100));
            // lnSeries_.MarkerType = MarkerType.Circle;
            thisPlotModel_.Series.Add(this.lnSeries_);            //ZoomToFit();


            if (!isfrmGammaCurve)
            {
                thisPlotModel_.Axes.Add(new OxyPlot.Axes.LinearAxis
                {
                    Position = OxyPlot.Axes.AxisPosition.Right,                   
                    TickStyle = OxyPlot.Axes.TickStyle.None,
                    IsAxisVisible = false
                });
                thisPlotModel_.Axes.Add(new OxyPlot.Axes.LinearAxis
                {
                    Position = OxyPlot.Axes.AxisPosition.Top,                    
                    TickStyle = OxyPlot.Axes.TickStyle.None,
                    IsAxisVisible = false
                });
            }
            else
            {
                thisPlotModel_.Axes.Add(new OxyPlot.Axes.LinearAxis
                {
                   
                    Position = OxyPlot.Axes.AxisPosition.Right,
                    MajorStep = 12.5,
                    TickStyle = OxyPlot.Axes.TickStyle.None,
                    MajorGridlineStyle = LineStyle.Solid,
                    MajorGridlineColor = OxyColors.YellowGreen,
                    TextColor = OxyColors.Brown,
                    IsAxisVisible = true
                }) ;
                thisPlotModel_.Axes.Add(new OxyPlot.Axes.LinearAxis
                {
                   
                    Position = OxyPlot.Axes.AxisPosition.Top,
                    MajorStep = 12.5,
                    MajorGridlineStyle = LineStyle.Solid,
                    MajorGridlineColor = OxyColors.YellowGreen,
                    TextColor = OxyColors.Brown,
                    TickStyle = OxyPlot.Axes.TickStyle.None,
                    IsAxisVisible = true
                });
                thisPlotModel_.Background = OxyColors.Brown;
                pointAnnotation_ = new PointAnnotation[this.lnSeries_.Points.Count];
                for (int pIdx = 0; pIdx < this.lnSeries_.Points.Count; pIdx++)
                {
                    pointAnnotation_[pIdx] = new PointAnnotation();
                    pointAnnotation_[pIdx].Shape = MarkerType.Diamond;
                    pointAnnotation_[pIdx].Selectable = true;
                    pointAnnotation_[pIdx].X = pIdx*12.5;
                    pointAnnotation_[pIdx].Y = pIdx*12.5;
                    thisPlotModel_.Annotations.Add(pointAnnotation_[pIdx]);
                }
               
               
            }

          

            this.xyPlot.Model = this.thisPlotModel_;

            this.thisPlotModel_.InvalidatePlot(true);

            this.xyPlot.Model.MouseMove += Model_MouseMove;
            this.xyPlot.Model.MouseDown += Model_MouseDown;
            this.xyPlot.Model.MouseUp += Model_MouseUp; ;
            ZoomToFit();
            this.xyPlot.Model = this.thisPlotModel_;
            Application.DoEvents();
            Application.DoEvents();

        }
        public void SetLinear()
        {
            //this.pointAnnotation_ = new PointAnnotation[this.lnSeries_.Points.Count];
            if (this.pointAnnotation_ != null)
            {
                for (int pIdx = 0; pIdx < this.lnSeries_.Points.Count; pIdx++)
                {
                    pointAnnotation_[pIdx] = new PointAnnotation();
                    pointAnnotation_[pIdx].Shape = MarkerType.Diamond;
                    pointAnnotation_[pIdx].Selectable = true;
                    pointAnnotation_[pIdx].X = pIdx * 12.5;
                    pointAnnotation_[pIdx].Y = pIdx * 12.5;
                }
                updateLineSeries();
            }
        }
        void updateLineSeries()
        {
            if(thisPlotModel_!= null)
            {
                thisPlotModel_.Series.Clear();
            }
            this.lnSeries_ = new LineSeries();

           // this.lnSeries_.Points.Add(new OxyPlot.DataPoint(0, 0));
            foreach(var pts in pointAnnotation_)
                this.lnSeries_.Points.Add(new OxyPlot.DataPoint(pts.X, pts.Y));

           // this.lnSeries_.Points.Add(new OxyPlot.DataPoint(100, 100));
            // lnSeries_.MarkerType = MarkerType.Circle;
            thisPlotModel_.Series.Add(this.lnSeries_);
            this.thisPlotModel_.Annotations.Clear();
            foreach (var ptAnnotate in this.pointAnnotation_)
                this.thisPlotModel_.Annotations.Add(ptAnnotate);
            this.xyPlot.Model = this.thisPlotModel_;

            this.thisPlotModel_.InvalidatePlot(true);
        }
        public void SetLineSeries(LineSeries lnSeries)
        {
            if (thisPlotModel_ != null)
            {
                thisPlotModel_.Series.Clear();
            }
            this.lnSeries_ = new LineSeries();
                       
            foreach (var pts in lnSeries.Points)
                this.lnSeries_.Points.Add(pts);

            thisPlotModel_.Series.Add(lnSeries_);
            this.xyPlot.Model = this.thisPlotModel_;

            this.thisPlotModel_.InvalidatePlot(true);
        }
        private void Model_MouseUp(object sender, OxyMouseEventArgs e)
        {
            if (isfrmGammaCurve_)
            {
                if (getHoveredCursor(e.Position) >= 0 && isDrag)
                {                    
                    this.pointAnnotation_[selectedPointIdx].Y = OxyPlot.Axes.Axis.InverseTransform(e.Position, this.thisPlotModel_.DefaultXAxis, this.thisPlotModel_.DefaultYAxis).Y;
                    this.thisPlotModel_.InvalidatePlot(true);
                   
                }
            }
            isDrag = false;
        }

        private void Model_MouseDown(object sender, OxyMouseDownEventArgs e)
        {
            if (isfrmGammaCurve_)
            {
                if (getHoveredCursor(e.Position) >=0 )
                {
                    if(e.ChangedButton == OxyMouseButton.Left)
                    {
                        isDrag = true;
                        // this.pointAnnotation_[selectedPointIdx].X = this.pointAnnotation_[selectedPointIdx].InverseTransform(e.Position).X;
                        //  this.pointAnnotation_[selectedPointIdx].Y = this.pointAnnotation_[selectedPointIdx].InverseTransform(e.Position).Y;
                        //  this.thisPlotModel_.InvalidatePlot(true);
                        
                        e.Handled = true;
                    }
                    else
                    {
                        isDrag = false;
                    }
                    
                }
                else
                {
                    isDrag = false;
                }
            }
        }
        int getHoveredCursor(ScreenPoint position)
        {
            for (int idx = 0; idx < this.pointAnnotation_.Length; idx++)
            {
                HitTestResult htr = this.pointAnnotation_[idx].HitTest(new HitTestArguments(position, 2));
                if (htr != null)
                {
                    selectedPointIdx = idx;
                  return idx;
                }              
            }           
            return -1;
        }
        private void Model_MouseMove(object sender, OxyMouseEventArgs e)
        {
            ZoomToFit();
            if(isfrmGammaCurve_)
            {
                if (getHoveredCursor(e.Position) >= 0 && isDrag)
                {
                    this.xyPlot.Cursor = System.Windows.Forms.Cursors.Cross;
                    this.pointAnnotation_[selectedPointIdx].Y = OxyPlot.Axes.Axis.InverseTransform(e.Position, thisPlotModel_.DefaultXAxis, this.thisPlotModel_.DefaultYAxis).Y;
                    this.thisPlotModel_.InvalidatePlot(false);
                    updateLineSeries();
                }
                else
                {
                    this.xyPlot.Cursor = System.Windows.Forms.Cursors.Default;
                }
            }
          
        }

        public void ZoomToFit()
        {
            if (this.lnSeries_ != null)
            {
                this.thisPlotModel_.Axes[1].Zoom(0, 100);
                this.thisPlotModel_.Axes[0].Zoom(0, 100);

                this.RePlot(true);
            }

        }
        public void RePlot(bool fullRedraw)
        {
            if (this.lnSeries_ != null)
            {
                this.thisPlotModel_.InvalidatePlot(true);
            }
        }
        public void SetCurve(double[] ptsX,double[] ptsY)
        {
            for(int pidx=0;pidx<ptsX.Length;pidx++)
            {
                this.pointAnnotation_[pidx].X = ptsX[pidx];
                this.pointAnnotation_[pidx].Y = ptsY[pidx];
            }
            this.thisPlotModel_.InvalidatePlot(false);
            updateLineSeries();
        }
    }
}
