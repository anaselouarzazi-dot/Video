import { Composition } from "remotion";
import { Intro, introSchema } from "./Intro";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="Intro"
      component={Intro}
      durationInFrames={150}
      fps={30}
      width={1920}
      height={1080}
      schema={introSchema}
      defaultProps={{ title: "Video Studio", subtitle: "Remotion · HyperFrames · FFmpeg" }}
    />
  );
};
