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
    public partial class frmCapture : WeifenLuo.WinFormsUI.Docking.DockContent
    {
        int selectedIdx = 0;
        bool isSelected = false;
        PictureBox currentPbx_;
        public frmCapture()
        {
            InitializeComponent();
            this.CloseButtonVisible = false;
        }
        public void capturedImage(double[,] currentFrameData,Bitmap currentImg)
        {
            if (isSelected)
            {
                currentPbx_.Image = currentImg;
                this.imgList.Images[selectedIdx] = currentImg;
                clsConstant.Instance.allSavedData_[selectedIdx] = currentFrameData;
                clsConstant.Instance.allSavedData_.Add(currentFrameData);
            }
            else
            {
                selectedIdx = this.imgList.Images.Count;
                currentPbx_ = new PictureBox();
                currentPbx_.Name = "pbx_" + selectedIdx;
                currentPbx_.Size = new Size(150, 150);
                currentPbx_.SizeMode = PictureBoxSizeMode.StretchImage;
                this.imgList.Images.Add(currentImg);
                currentPbx_.Image = currentImg;
                clsConstant.Instance.allSavedData_.Add(currentFrameData);
                currentPbx_.Dock = System.Windows.Forms.DockStyle.Left;
                currentPbx_.MouseDoubleClick += Pic_MouseDoubleClick;
                this.Controls.Add(currentPbx_);
                selectedIdx++;
            }
            isSelected = false;
           
            currentPbx_.BorderStyle = BorderStyle.None;

        }

        private void Pic_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            currentPbx_ = (PictureBox)sender;
            selectedIdx = Convert.ToInt32(currentPbx_.Name.Split('_')[1]);
            currentPbx_.BorderStyle = BorderStyle.Fixed3D;
            isSelected = true;
        }
    }
}
