#!/bin/bash


##############this block is used to convert cul command output to simple text##########
json2bash()
{
perl -MJSON -0777 -n -E 'sub J {
  my ($p,$v) = @_; my $r = ref $v;
  if ($r eq "HASH") { tr/-A-Za-z0-9_//cd, J("${p}_$_", $v->{$_}) for keys %$v; }
  elsif ($r eq "ARRAY") { $n = 0; J("$p"."[".$n++."]", $_) foreach @$v; }
  else { $v =~ '"s/'/'\\\\''/g"'; $p =~ s/^([^[]*)\[([0-9]*)\](.+)$/$1$3\[$2\]/;
  $p =~ tr/-/_/; $p =~ tr/A-Za-z0-9_[]//cd; say "$p='\''$v'\'';"; }
  }; J("json", decode_json($_));'
}

############## create tag according to folder name######################################################
############## $1 has folder name ######################################################################
tag=$1
git tag $tag
git push origin $tag

################repo name should be given by user where the release should be created###################
repo_full_name="rmunde1493/temp"

################User needs to generate and store github token in git global config######################
token=$(git config --global github.token)
text="creating release $1"

generate_post_data()
{
  cat <<EOF
{
  "tag_name": "$tag",
  "name": "$tag",
  "body": "$text",
  "draft": false,
  "prerelease": false
}
EOF
}

################ This block create release by using curl command########################################
echo "Create release $version for repo: $repo_full_name"
res=$(curl --data "$(generate_post_data)" "https://api.github.com/repos/$repo_full_name/releases?access_token=$token" )
eval "$(json2bash <<<"$res")"
#echo $res


################ This block is used to upload zip file to resp release##################################
upload_url="https://uploads.github.com/repos/$repo_full_name/releases/$json_id/assets"
echo $upload_url
curl -H "Authorization: token $token"  \
        -H "Content-Type: application/zip" \
        --data-binary @$1.zip  \
        "$upload_url?name=$1.zip&label=$1.zip"




