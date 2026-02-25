{ pkgs, ... }:
{
	programs.yazi = {
		enable = true;
		enableBashIntegration = true;
		shellWrapperName = "y"; # use `y` to get cd-on-quit behaviour

		extraPackages = with pkgs; [
			ffmpegthumbnailer # video thumbnails
			poppler-utils # PDF previews
			imagemagick # image conversion/previews
			file # MIME type detection
			p7zip # archive previews
		];

		settings = {
			manager = {
				show_hidden = false;
				sort_by = "natural";
				sort_dir_first = true;
			};
			preview = {
				image_quality = 90;
			};
		};
	};
}
