using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;


//class Program
//{
//    static void Main()
//    {
//        LaunchCommandLineApp();
//    }
//    /// <summary>
//    /// Launch the application with some options set.
//    /// </summary>
//    static void LaunchCommandLineApp()
//    {
//        // For the example
//        const string ex1 = "C:\\";
//        const string ex2 = "C:\\Dir";
//        // Use ProcessStartInfo class
//        ProcessStartInfo startInfo = new ProcessStartInfo();
//        startInfo.CreateNoWindow = false;
//        startInfo.UseShellExecute = false;
//        startInfo.FileName = "dcm2jpg.exe";
//        startInfo.WindowStyle = ProcessWindowStyle.Hidden;
//        startInfo.Arguments = "-f j -o \"" + ex1 + "\" -z 1.0 -s y " + ex2;
//        try
//        {
//            // Start the process with the info we specified.
//            // Call WaitForExit and then the using statement will close.
//            using (Process exeProcess = Process.Start(startInfo))
//            {
//                exeProcess.WaitForExit();
//            }
//        }
//        catch
//        {
//            // Log error.
//        }
//    }
//try
//{
//    System.Diagnostics.Process.Start("BeamFormCUDA.exe");
//}
//catch (Exception e1)
//{
//    Console.WriteLine(e1.Message);
//}
//}



namespace ManagedImageForm
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void tableLayoutPanel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void showButton_Click(object sender, EventArgs e)
        {
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                pictureBox1.Load(openFileDialog1.FileName);
            }
        }

        private void clearButton_Click(object sender, EventArgs e)
        {
            // Clear the picture.
            pictureBox1.Image = null;
        }

        private void backgroundButton_Click(object sender, EventArgs e)
        {
            // Show the color dialog box. If the user clicks OK, change the
            // PictureBox control's background to the color the user chose.
            if (colorDialog1.ShowDialog() == DialogResult.OK)
                pictureBox1.BackColor = colorDialog1.Color;
        }

        private void closeButton_Click(object sender, EventArgs e)
        {

            //Close the form.
            this.Close();
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            // If the user selects the Stretch check box, 
            // change the PictureBox's
            // SizeMode property to "Stretch". If the user clears 
            // the check box, change it to "Normal".
            if (checkBox1.Checked)
                pictureBox1.SizeMode = PictureBoxSizeMode.StretchImage;
            else
                pictureBox1.SizeMode = PictureBoxSizeMode.Normal;
        }
    }
}
