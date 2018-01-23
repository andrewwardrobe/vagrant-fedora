# Developer Vagrant

Fedora-Kde Vagrant Environment with:
* Puppet
* Ansible
* Docker
* Docker Compose
* intellij community

## data.yaml
The image can be customised, to install additional user, or software such as rubymine or intellij ultimate

User can be installed by adding a hash of users to the data.yaml file for example (This will create a user called demo with a password of Pass123!):
```yaml
users:
  demo:
    name: Davidius Emo
    email: demo@example.com
    # if you have a dotfiles repo uncomment this line and put the path here    
    # dotfiles: https://github.com/andrewwardrobe/dotfiles.git
    # Generate this with 'openssl passwd -1' in this case the password is Pass123!
    passwd: $1$oemdTVg9$.yA8PD/KIxAG/g/VPk7AX.  
    # if you have access to nfs servers etc this should match your uid on those servers to avoid file permission errors
    uid: 7001
    # if you wish for a rsa key to be added to the user put it here I dont not recommend using this one
    # the password for this key is Pass123!
    id_rsa: | 
      -----BEGIN RSA PRIVATE KEY-----
      Proc-Type: 4,ENCRYPTED
      DEK-Info: AES-128-CBC,5D5FF18AD9C773EFF070231A8630E70A

      ZiGg0AqrCyvZzDLnTtRKLNuyz4I8x5TX6sUQ2voOg/DDNUwmI8c2qCszyMUgGkzy
      45X5acA0OJH12zZi5P6MFy5E0KmFhZ7QQvxUQbHmBpUtaEu9NA2XzGIZsZ/RD+R5
      OUPR/JdydqQIYYtpSxadDoL5BuNMAkboATI5s3OGK8rzXCHSoXb88gpX14DKkYZZ
      +C+5CYlLtJ1jsewN5gk3PRquOGmeEmSN4mH+yCl90yu+1TMeg3g+EjkdMdu9qiUT
      jGoFjOWBTtVpCO784e90/s8qpFzSIMx0wXabN9IH1rnzjJH2ga+Q3Mv7GiwMHIaw
      jmpqIe97Rp6T6Y8pbykpwImHJwy7RC4Zp4Ww43SEu1Vb7f+kjKpUeAbnnxss2HjN
      N9O6/LBNM9I1DbDunJvTMtxwf1xcGZbp3VFfa0P6Jw3M89q4TlAFZ0urhcVPVcsx
      mexoJFr/Pe04CNbHUVxOmzZOniOYK3G5fPTgGJ8D1qxY/kcnRscpTz0pYifJYOtN
      gzjczpYUXgnAir2n1lm+qKbRrevqDoh6nCd/wHP3ABmN0kUjCb8dVlKvbPv+Hddx
      96zv58CR134sZUcFB2Myo8tRqzmCTp2WiebIiSNUJcYodx5GfLssrsd/vVviOOFB
      s7JI1SGjljkRYYRw+sL0+gcJtQp8RkMtXi7BWVCRjlXbYBcrs1dyYPDE3jrxoAky
      +uvOIFDVipB2K6sWwkQSFrBWJQvKj5LHm7TOgnIR8yTewGQOM1jWrDsLYY0PC1YR
      3+s/9dtE6Rm8jy13jeHZHhM3JHc1AkoSSwiwJ5SKjgDRPDaXML8eAewxY9VfvhdI
      ISvPe4L/4l+UAiYK3/+2dfyeE3/TbgAUwMAnpd/xU+DOiU75qAaLMIzyhVJut9yJ
      H4o42tA8Sa2LwPka5kFEnkbv2q3Mh3xhTsa/tH5UqSrYK1aOn7RnPrnszszCb69Q
      OYA0bHvZWf+/YT7u/F5DoK9n2Fdme0prTMrslMbTZpaWeiKXFKc83ZZDTT7ZKMfn
      uU7wENhtwOy8bBUfOwprHz3u71l5KYWW7DfpUNraAKI4kbDYiksOlrvLF9iVLvf1
      BniKGcA+WA/XCYxDFadENx1YvJMpi4kvvEyxSnRUERyrIety0MrGLolqYE9PPPpM
      lMDKs0BQbn+n9dljNalWZptsVtIeZlr142HwZz+C570MOoopnf/X2baFitBuZwi1
      5mDgOEKSCmMBFPUqkeOoNG0cJw+KK2aNDaw3F1G7c5ixkDYzcNP8y/80GDialxCT
      gOH7llHWayMtxjSmMnTOTWfZ8nVsh0/fb5b9UETPyZGdF7bEThHgwnKOkxUq6alY
      ayj8SlNq2BC4oSE+p8wrbBgj9cZo/IkghB9sgSPoz80zTKO+l/yikPsUCILaG191
      tCook1VlscFvbeNM44gv9brKSb340b+8W4XetJ9WN6ijjqiOasSktmqjUUQf8FL7
      7IcRy+sJBf4WJqqZmd5XMdzJiJrSSzU3R7Z9DnRLEApWAJccS4dymqz7n0GQp8P7
      BJMFGufPtJ0Png9r7Rw3XekoUmbjRFHX5jdzdOKsFgXqhsC+ROVMC/C9MzGafgds
      -----END RSA PRIVATE KEY-----
   # This get added to ~/.ssh/id_rsa.pub for convience
   public_key: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvgZGgBewYMJrxRoIT+yoeiR2NON9WxJ0682IDhyMcJe5qxHcTJUKcmD/2RquDspvjzZqszp8dxY4VNyS3d4D9r6fsxc0V0ao7ixX6k4jNoVplzk0mOL6wmCLyhBxdNltHbFSQp3Q8YRXOnjES3NRZhDV1irE1wbTZFAb25gAJE4NoFXAQsXeYSn6QoPBU8iD/MXQJjVSnRFbETgFpVp+Kxqca6eDknUizWnrNRXzccSVT9Fx9Er2NUBxs0WBTSBzjAnwycCJJDsdUB1mstT95aOIwmadjiST5o9DxFqN3ycqhPqQJDj9SqIe7NEHLgwvAewfPnBnvhDRfnTi4v83N example@pubkey

   
#Uncomment to install intellij ultimate and the below pligins   
# intellij_ultimate:
#   install: true
#   plugins:
#     puppet: https://plugins.jetbrains.com/plugin/download?updateId=41058                                                                                                                                                  
#     gerrit-intellij-plugin: https://plugins.jetbrains.com/plugin/download?updateId=42037
#     jenkins-control-plugin-0.10.2016: https://plugins.jetbrains.com/plugin/download?updateId=32596
#     Docker: https://plugins.jetbrains.com/plugin/download?updateId=40538
#     vagrant: https://plugins.jetbrains.com/plugin/download?updateId=41069
#     atlassian-idea-plugin: https://plugins.jetbrains.com/plugin/download?updateId=19501
#     ruby: https://plugins.jetbrains.com/plugin/download?updateId=41888

#Uncomment to install rubymine and the below pligins 
# rubymine:
#   install: true
```
