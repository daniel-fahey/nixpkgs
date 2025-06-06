{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "airscan";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "stapelberg";
    repo = "airscan";
    tag = "v${version}";
    hash = "sha256-gk0soDzrsFBh+SrWcfO/quW6JweX6MthOigTHcaq1oE=";
  };

  vendorHash = "sha256-I5JRGaff6OIwx4q7BjpFwvJiQe4kw03V8+McYPcJhho=";

  meta = {
    description = "Package to scan paper documents using the Apple AirScan (eSCL) protocol";
    mainProgram = "airscan1";
    homepage = "https://github.com/stapelberg/airscan";
    changelog = "https://github.com/stapelberg/airscan/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ johannwagner ];
  };
}
