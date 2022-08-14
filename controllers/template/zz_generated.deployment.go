//go:build !ignore_autogenerated

/*
Copyright  The KubeVela Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Code generated by ../../hack/generate-go-const-from-file.sh. DO NOT EDIT.

// Instead, edit yaml/deployment.yaml and regenerate this using go generate ./...

package template

const deploymentTemplate = `apiVersion: apps/v1
kind: Deployment
metadata:
  name: kube-trigger-example
  namespace: default
  labels:
    app.kubernetes.io/created-by: kube-trigger-manager
    app.kubernetes.io/component: kube-trigger
    app.kubernetes.io/version: latest
    app.kubernetes.io/name: kube-trigger-example
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: kube-trigger-example
  replicas: 1
  template:
    metadata:
      labels:
        app.kubernetes.io/name: kube-trigger-example
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
        - workingDir: /
          image: oamdev/kube-trigger:latest
          imagePullPolicy: IfNotPresent
          name: kube-trigger
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - "ALL"
          resources:
            limits:
              cpu: 500m
              memory: 128Mi
            requests:
              cpu: 10m
              memory: 64Mi
          volumeMounts:
            - mountPath: /config.cue
              name: config
              subPath: config.cue
      serviceAccountName: kube-trigger-example
      terminationGracePeriodSeconds: 10
      volumes:
        - name: config
          configMap:
            name: kube-trigger-example
            items:
              - key: config.cue
                path: config.cue
`
