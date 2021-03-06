﻿module egret3d {

    /*
    * @private
    */
    export class Gbuffer implements IPost{

        public renderQuen: RenderQuen;
        public drawRectangle: Rectangle;

        private postRender: PostRender;

        private _debugHud: HUD = new HUD();
        constructor() {
            this.postRender = new PostRender("hud_vs", "gaussian_H_fs");
        }

        public setRenderTexture(width: number, height: number) {
            this.postRender.setRenderToTexture(width, height);
        }

        public draw(time: number, delay: number, context3D: Context3DProxy, collect: EntityCollect, camera: Camera3D, backViewPort: Rectangle, posList: any) {
            this.postRender.camera = camera;
            this.postRender.needClean = true;
            this.postRender.draw(time, delay, context3D, collect,  backViewPort, posList);
            posList["final"] = this.postRender.renderTexture ;
        }
    }
}