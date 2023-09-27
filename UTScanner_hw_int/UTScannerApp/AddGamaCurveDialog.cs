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
    public partial class AddGamaCurveDialog : Form
    {
        public AddGamaCurveDialog()
        {
            InitializeComponent();
            this.txtCurveName.Text = clsConstant.Instance.CurrentCurveName;
        }

        private void btnOk_Click(object sender, EventArgs e)
        {
            clsConstant.Instance.CurrentCurveName = this.txtCurveName.Text;
            this.Close();
        }
    }
}
