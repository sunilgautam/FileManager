using System.Collections.Generic;

namespace FileBrowser
{
    public class FBDirectory
    {
        public string Name { get; set; }
        public string Path { get; set; }
        public int NoOfFiles { get; set; }
        public int NoOfDirectories { get; set; }
        public List<FBFile> files = null;
        public List<FBDirectory> directories = null;
        public FBDirectory()
        {
            files = new List<FBFile>();
            directories = new List<FBDirectory>();
        }

        public void AddFile(FBFile file)
        {
            // Search for existing entry
            for (int i = 0; i < files.Count; i++)
			{
                if (files[i].Name == file.Name)
                {
                    return;
                }
			}

            files.Add(file);
        }

        public void AddDirectory(FBDirectory directory)
        {
            // Search for existing entry
            for (int i = 0; i < directories.Count; i++)
            {
                if (directories[i].Name == directory.Name)
                {
                    return;
                }
            }

            directories.Add(directory);
        }
    }
}