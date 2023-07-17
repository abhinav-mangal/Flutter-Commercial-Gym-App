# gym_app

Flutter project using Flutter v3.7.12.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Build process
1. Push latest code to `main` branch
2. Save git token - `TOKEN=replace_with_github_personal_access_token`
3. Save version + build number that we want to deploy - `BUMP_TYPE=patch|minor|major --bump-build`
   1. If you want to start pre-release, then send `BUMP_TYPE="patch --pre=alpha --bump-build"`
   2. If you want to update pre-release, then send `BUMP_TYPE=pre`
   3. If you want to convert pre to prod release, then send `BUMP_TYPE=patch|minor|major`
4. Run curl command locally to trigger `update_version` dispatch which will create the tag.
   ```
   curl -X POST -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github.everest-preview+json" -H "Content-Type: application/json" https://api.github.com/repos/energym/Flutter-Commercial-Gym-App/dispatches --data '{"event_type": "update-version", "client_payload": {"bump_type": "'${BUMP_TYPE}'", "token": "'${TOKEN}'"}}'
   ```
5. Download artifact from action for latest version

# Release process
1. Save git token - `TOKEN=replace_with_github_personal_access_token`
2. Save version + build number that we want to deploy - `VERSION=v1.0.0+1`
3. Run curl command locally to trigger `upload_build_to_firebase` dispatch which will upload the mentioned version to firebase
   ```
   curl -X POST -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github.everest-preview+json" -H "Content-Type: application/json" https://api.github.com/repos/energym/Flutter-Commercial-Gym-App/dispatches --data '{"event_type": "upload-build", "client_payload": {"version": "'${VERSION}'", "token": "'${TOKEN}'"}}'
   ```
