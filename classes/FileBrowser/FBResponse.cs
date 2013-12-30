namespace FileBrowser
{
    public class FBResponse
    {
        public FBDirectory directory { get; set; }
        public string error { get; set; }
        public FBResponse()
        {
            directory = new FBDirectory();
            error = "success";
        }
    }
}