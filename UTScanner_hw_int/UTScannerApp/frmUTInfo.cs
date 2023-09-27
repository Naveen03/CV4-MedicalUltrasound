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
    public partial class frmUTInfo : WeifenLuo.WinFormsUI.Docking.DockContent
    {
       
        //private static frmUTInfo instance_;
        //public static frmUTInfo Instance
        //{
        //    get
        //    {
        //        if (instance_ == null)
        //            instance_ = new frmUTInfo();
        //        return instance_;
        //    }
        //}
        public frmUTInfo()
        {
            InitializeComponent();
            this.CloseButtonVisible = false;
        
        }

     


        public void loadUTInfo(double sampleFrq,double maxDepth,double apertureSize)
        {
            this.lblSampleFrq.Text = sampleFrq + " MHz";
            this.lblMaxDepth.Text = maxDepth.ToString();
            this.lblApertureSize.Text = apertureSize.ToString();
            this.lblProbeType.Text = clsConstant.Instance.probeType == 1 ? "Type A" : "Type B";
        }

       
    }
}
