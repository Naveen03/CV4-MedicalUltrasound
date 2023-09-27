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
    public partial class frmApplication :  WeifenLuo.WinFormsUI.Docking.DockContent
    {
        string[] humanType;
        int selectedHumanIdx_;
        public frmApplication()
        {
            InitializeComponent();
            
            this.tip.SetToolTip(this.btnBladder,"Bladder");
            this.tip.SetToolTip(this.btnGlottis, "Glottis");
            this.tip.SetToolTip(this.btnHeart, "Heart");
            this.tip.SetToolTip(this.btnKidney, "Kidney");
            this.tip.SetToolTip(this.btnLegBone, "LegBone");
            this.tip.SetToolTip(this.btnLung, "Lung");
            this.tip.SetToolTip(this.btnNeuron, "Neuron");
            this.tip.SetToolTip(this.btnSpinal, "Spinal");
            this.tip.SetToolTip(this.btnSpleen, "Spleen");
            this.tip.SetToolTip(this.btnBreast, "Breast");
            this.tip.SetToolTip(this.btnUterus, "Uterus");


            this.humanType = new string[3];
           
            this.humanType[0] = "Male";
            this.humanType[1] = "Female";
            this.humanType[2] = "Baby";
            this.selectedHumanIdx_ = 0;
            LoadHumanType();
            
        }

        private void btnNext_Click(object sender, EventArgs e)
        {
            if(this.selectedHumanIdx_ < this.humanType.Length-1)
            {
                this.selectedHumanIdx_++;                
            }
            else
            {
                this.selectedHumanIdx_ = 0;
            }
            LoadHumanType();
        }

        private void btnPrev_Click(object sender, EventArgs e)
        {
            if (this.selectedHumanIdx_ > 0)
            {
                this.selectedHumanIdx_--;
            }
            else
            {
                this.selectedHumanIdx_ = this.humanType.Length -1;
            }
            LoadHumanType();
        }
        void LoadHumanType()
        {
            if(this.humanType[this.selectedHumanIdx_].Equals("Baby"))
            {
                this.btnBladder.Visible = false;
                this.btnGlottis.Visible = false;
                this.btnHeart.Visible = true;
                this.btnKidney.Visible = false;
                this.btnLegBone.Visible = false;
                this.btnLung.Visible = false;
                this.btnNeuron.Visible = false;
                this.btnSpinal.Visible = false;
                this.btnSpleen.Visible = false;
                this.btnUterus.Visible = false;
                this.btnBreast.Visible = false;
            }
            else if(this.humanType[this.selectedHumanIdx_].Equals("Male"))
            {
                this.btnBladder.Visible = true;
                this.btnGlottis.Visible = true;
                this.btnHeart.Visible = true;
                this.btnKidney.Visible = true;
                this.btnLegBone.Visible = true;
                this.btnLung.Visible = true;
                this.btnNeuron.Visible = true;
                this.btnSpinal.Visible = true;
                this.btnSpleen.Visible = true;
                this.btnUterus.Visible = false;
                this.btnBreast.Visible = false;
            }
            else if (this.humanType[this.selectedHumanIdx_].Equals("Female"))
            {               
                this.btnGlottis.Visible = true;
                this.btnHeart.Visible = true;
                this.btnKidney.Visible = true;
                this.btnLegBone.Visible = true;
                this.btnLung.Visible = true;
                this.btnNeuron.Visible = true;
                this.btnSpinal.Visible = true;
                this.btnSpleen.Visible = true;
                this.btnUterus.Visible = true;
                this.btnBreast.Visible = true;
                this.btnBladder.Visible = false;
            }

            this.lblCaption.Text = this.humanType[this.selectedHumanIdx_];
            this.pbxHumanType.Image = new Bitmap(Application.StartupPath + "\\" + this.humanType[this.selectedHumanIdx_] + ".png");
        }
    }
}
